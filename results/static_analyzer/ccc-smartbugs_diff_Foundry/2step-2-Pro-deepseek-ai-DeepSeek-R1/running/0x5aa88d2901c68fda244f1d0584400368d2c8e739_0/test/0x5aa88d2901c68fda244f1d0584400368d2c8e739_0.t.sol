// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x5aa88d2901c68fda244f1d0584400368d2c8e739.sol";

contract MultiplicatorX3Test is Test {
    MultiplicatorX3 public multiplicator;
    address public owner;
    address public beneficiary;
    address public funder;
    
    function setUp() public {
        owner = makeAddr("owner");
        beneficiary = makeAddr("beneficiary");
        funder = makeAddr("funder");
        
        vm.prank(owner);
        multiplicator = new MultiplicatorX3();
    }

    function test_CannotActivatePayoutWhenFunded() public {
        // Fund contract through direct transfer
        vm.deal(funder, 1 ether);
        vm.prank(funder);
        payable(address(multiplicator)).transfer(0.1 ether);
        
        // Give regular user some test funds
        address user = makeAddr("user");
        vm.deal(user, 2 ether);

        console.log("--- BEFORE-Trigger multiplicate ---");
        uint beneficiaryBalanceBefore = address(beneficiary).balance;
        uint contractBalanceBefore = address(multiplicator).balance;
        console.log("Beneficiary ETH balance:", beneficiaryBalanceBefore);
        console.log("Contract ETH balance:", contractBalanceBefore);

        console.log("--- Trigger multiplicate function ---");
        vm.prank(user);
        multiplicator.multiplicate{value: 0.1 ether}(beneficiary);

        console.log("--- AFTER-Trigger multiplicate ---");
        uint beneficiaryBalanceAfter = address(beneficiary).balance;
        uint contractBalanceAfter = address(multiplicator).balance;
        console.log("Beneficiary ETH balance:", beneficiaryBalanceAfter);
        console.log("Contract ETH balance:", contractBalanceAfter);

        bool fundsNotTransferred = beneficiaryBalanceAfter == beneficiaryBalanceBefore;
        console.log("Funds transferred to beneficiary:", 
            fundsNotTransferred ? "NO" : "YES, Unexpected success");
        console.log("Contract ETH increase:", contractBalanceAfter - contractBalanceBefore);
        
        if (fundsNotTransferred) {
            console.log("Vulnerability Exists: Unable to activate payout when contract is funded");
        } else {
            console.log("Vulnerability not Exist: Successfully transferred to beneficiary");
        }
    }

    function test_PayoutConditionAlwaysFailsWhenFunded() public {
        bool vulnerabilityExists = true;
        
        // Fund contract with small amount
        vm.deal(funder, 1 ether);
        vm.prank(funder);
        payable(address(multiplicator)).transfer(0.1 ether);

        address user = makeAddr("user");
        vm.deal(user, 2 ether);

        for (uint i; i < 5; i++) {
            uint sendAmount = 0.1 ether * (i + 1);
            
            console.log("\n--- Iteration %d ---", i + 1);
            console.log("--- BEFORE-Trigger multiplicate ---");
            uint beneficiaryBefore = address(beneficiary).balance;
            uint contractBefore = address(multiplicator).balance;
            console.log("Beneficiary ETH:", beneficiaryBefore);
            console.log("Contract ETH:", contractBefore);

            console.log("--- Trigger multiplicate with %d wei ---", sendAmount);
            vm.prank(user);
            (bool success, ) = address(multiplicator).call{value: sendAmount}(
                abi.encodeWithSelector(
                    MultiplicatorX3.multiplicate.selector,
                    beneficiary
                )
            );
            assertTrue(success, "Call failed unexpectedly");

            console.log("--- AFTER-Trigger multiplicate ---");
            uint beneficiaryAfter = address(beneficiary).balance;
            uint contractAfter = address(multiplicator).balance;
            console.log("Beneficiary ETH:", beneficiaryAfter);
            console.log("Contract ETH:", contractAfter);

            bool fundsTransferred = beneficiaryAfter > beneficiaryBefore;
            console.log("Funds transferred:", fundsTransferred ? "YES" : "NO");
            
            if (fundsTransferred) {
                vulnerabilityExists = false;
                console.log(">> Payout activated in iteration %d!", i + 1);
            }

            // Condition: sendAmount >= (currentBalance + sendAmount) 
            // is mathematically impossible for any balance > 0
            assertEq(address(beneficiary).balance, 0, "Payout activated unexpectedly");
        }

        if (vulnerabilityExists) {
            console.log("\nVulnerability Exists: No transfer succeeded in any iteration");
        } else {
            console.log("\nVulnerability not Exist: Transfer succeeded in at least 1 iteration");
        }
    }
}