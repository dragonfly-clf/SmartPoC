// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3e013fc32a54c4c5b6991ba539dcd0ec4355c859.sol";
import {console2} from "forge-std/console2.sol"; // Add console2 import

contract MultiplicatorX4Test is Test {
    MultiplicatorX4 public multiplicator;
    address owner = address(0x1);
    
    // Target contract that will reject ETH transfers
    ContractThatRejectsETH public rejector;

    function setUp() public {
        vm.prank(owner);
        multiplicator = new MultiplicatorX4();
        
        rejector = new ContractThatRejectsETH();
        
        // Fund the owner address
        vm.deal(owner, 1 ether);
    }

    function testUncheckedLowLevelCall() public {
        // Verify initial balances
        assertEq(owner.balance, 1 ether);
        assertEq(address(rejector).balance, 0);
        assertEq(address(multiplicator).balance, 0);
        
        // Prepare call data
        bytes memory data = abi.encodeWithSignature("nonExistentFunction()");
        
        // Record state BEFORE attack
        console2.log("--- BEFORE-Trigger Balances ---");
        uint256 ownerStartBalance = owner.balance;
        uint256 rejectorStartBalance = address(rejector).balance;
        uint256 multiplicatorStartBalance = address(multiplicator).balance;
        console2.log("Owner balance before:", ownerStartBalance);
        console2.log("Rejector balance before:", rejectorStartBalance);
        console2.log("Multiplicator balance before:", multiplicatorStartBalance);
        
        console2.log("--- Trigger Command call ---");
        // Execute Command function with owner privileges and value
        vm.prank(owner);
        multiplicator.Command{value: 1 ether}(address(rejector), data);
        
        // Record state AFTER attack
        console2.log("--- AFTER-Trigger Balances ---");
        uint256 ownerFinalBalance = owner.balance;
        uint256 rejectorFinalBalance = address(rejector).balance;
        uint256 multiplicatorFinalBalance = address(multiplicator).balance;
        console2.log("Owner balance after:", ownerFinalBalance);
        console2.log("Rejector balance after:", rejectorFinalBalance);
        console2.log("Multiplicator balance after:", multiplicatorFinalBalance);
        
        // Compare states to verify vulnerability
        bool ownerBalanceReduced = ownerFinalBalance == ownerStartBalance - 1 ether;
        bool rejectorUnchanged = rejectorFinalBalance == rejectorStartBalance;
        bool multiplicatorIncreased = multiplicatorFinalBalance == multiplicatorStartBalance + 1 ether;
        
        bool vulnerabilityExists = ownerBalanceReduced && rejectorUnchanged && multiplicatorIncreased;
        
        // Print final verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Owner's ETH was deducted but not sent to rejector, and stuck in MultiplicatorX4 contract due to failed transfer");
        } else {
            console2.log("Vulnerability not Exist: ETH was either successfully transferred or not deducted from owner");
        }

        // Keep original assertions for test integrity
        assertEq(address(rejector).balance, 0, "ETH should not have been transferred to rejector");
        assertEq(owner.balance, 0, "Owner's ETH should have been sent");
        assertGt(address(multiplicator).balance, 0, "ETH should be stuck in MultiplicatorX4");
    }
}

// Helper contract that will reject ETH transfers
contract ContractThatRejectsETH {
    // No payable fallback or receive function
    function nonExistentFunction() external pure returns (bool) {
        return true;
    }
}