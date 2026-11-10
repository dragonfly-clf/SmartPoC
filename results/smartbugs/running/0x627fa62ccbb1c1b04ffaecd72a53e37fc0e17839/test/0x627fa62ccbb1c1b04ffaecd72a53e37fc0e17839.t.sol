// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x627fa62ccbb1c1b04ffaecd72a53e37fc0e17839.sol";

contract TokenBankTest is Test {
    TokenBank tokenBank;
    address owner = address(0x1);
    address nonOwner = address(0x2);
    address tokenAddress = address(0x3);
    address recipient = address(0x4);

    // Mock token that will fail transfers
    MockFailingToken failingToken;

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        failingToken = new MockFailingToken();
        vm.stopPrank();
        
        // Fund the test contract
        vm.deal(address(this), 100 ether);
    }

    function testUncheckedTokenTransferFailure() public {
        // Set up initial conditions
        uint256 amount = 100 ether;

        console.log("--- BEFORE-Trigger ---");
        console.log("Expectation: WithdrawToken call with failing token should NOT revert");

        console.log("--- Trigger: WithdrawToken ---");
        // Start acting as owner
        vm.startPrank(owner);

        // Test with a failing token (should return false on transfer)
        tokenBank.WithdrawToken(address(failingToken), amount, recipient);

        vm.stopPrank();

        console.log("--- AFTER-Trigger ---");
        console.log("Action: WithdrawToken call completed without reverting");
        console.log("Vulnerability confirmed: Transaction succeeded despite token transfer failure");
        
        console.log("Vulnerability Exists: Unchecked low-level call return value in WithdrawToken allowed failed transfer without revert");
    }

    function testWithdrawTokenToHolderWithFailingToken() public {
        // Set up holder
        uint256 amount = 100 ether;
        
        // Deposit ETH first
        vm.startPrank(owner);
        vm.deal(owner, amount);
        tokenBank.Deposit{value: amount}();
        vm.stopPrank();

        console.log("--- BEFORE-Trigger ---");
        console.log("Expectation: WitdrawTokenToHolder call with failing token should NOT revert");

        console.log("--- Trigger: WitdrawTokenToHolder ---");
        vm.startPrank(owner);
        tokenBank.WitdrawTokenToHolder(recipient, address(failingToken), amount);
        vm.stopPrank();

        console.log("--- AFTER-Trigger ---");
        console.log("Action: WitdrawTokenToHolder call completed without reverting");
        console.log("Vulnerability confirmed: Transaction succeeded despite token transfer failure");
        
        console.log("Vulnerability Exists: Unchecked low-level call return value in WitdrawTokenToHolder allowed failed transfer without revert");
    }
}

contract MockFailingToken {
    // Always fails when transfer is called
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}