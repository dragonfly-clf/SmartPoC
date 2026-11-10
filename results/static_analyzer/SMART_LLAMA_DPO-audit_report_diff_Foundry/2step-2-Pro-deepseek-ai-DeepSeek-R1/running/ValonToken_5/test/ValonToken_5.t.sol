// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ValonToken.sol";

contract ValonTokenTest is Test {
    ValonToken token;
    address owner = vm.addr(1);
    address user = vm.addr(2);
    uint256 constant INITIAL_SUPPLY = 1000 ether;
    
    function setUp() public {
        vm.prank(owner);
        token = new ValonToken(INITIAL_SUPPLY);
        
        vm.prank(owner);
        token.transfer(user, 100 ether);
    }

    // Test basic transfer functionality
    function test_TransferWorks() public {
        uint256 userInitialBalance = token.balanceOf(user);
        uint256 ownerInitialBalance = token.balanceOf(owner);
        uint256 transferAmount = 10 ether;
        
        console.log("--- BEFORE-Trigger Transfer ---");
        console.log("User balance:", userInitialBalance);
        console.log("Owner balance:", ownerInitialBalance);
        
        console.log("--- Trigger Transfer Operation ---");
        vm.prank(user);
        token.transfer(owner, transferAmount);
        
        console.log("--- AFTER-Trigger Transfer ---");
        uint256 userFinalBalance = token.balanceOf(user);
        uint256 ownerFinalBalance = token.balanceOf(owner);
        console.log("User balance:", userFinalBalance);
        console.log("Owner balance:", ownerFinalBalance);
        
        // Validation logic
        uint256 userDiff = userInitialBalance - userFinalBalance;
        uint256 ownerDiff = ownerFinalBalance - ownerInitialBalance;
        bool userCorrect = userDiff == transferAmount;
        bool ownerCorrect = ownerDiff == transferAmount;
        
        console.log("User balance change: %s (%s)", 
            userDiff, 
            userCorrect ? "CORRECT" : "WRONG - Expected:10 ether");
        console.log("Owner balance change: %s (%s)", 
            ownerDiff, 
            ownerCorrect ? "CORRECT" : "WRONG - Expected:10 ether");
        
        // Vulnerability determination
        if (userCorrect && ownerCorrect) {
            console.log("Vulnerability not Exist: Token transfers function correctly with expected state changes");
        } else {
            console.log("Vulnerability Exists: Unexpected token transfer behavior indicating security flaw");
        }
    }

    // Test transferFrom with allowance
    function test_TransferFromWorks() public {
        uint256 allowanceAmount = 50 ether;
        uint256 transferAmount = 30 ether;
        uint256 userInitialBalance = token.balanceOf(user);
        uint256 ownerInitialBalance = token.balanceOf(owner);
        
        // Setup approval
        vm.prank(user);
        token.approve(address(this), allowanceAmount);
        
        console.log("--- BEFORE-Trigger TransferFrom ---");
        uint256 initialAllowance = token.allowance(user, address(this));
        console.log("User balance:", userInitialBalance);
        console.log("Owner balance:", ownerInitialBalance);
        console.log("Allowance balance:", initialAllowance);
        
        console.log("--- Trigger TransferFrom Operation ---");
        token.transferFrom(user, owner, transferAmount);
        
        console.log("--- AFTER-Trigger TransferFrom ---");
        uint256 userFinalBalance = token.balanceOf(user);
        uint256 ownerFinalBalance = token.balanceOf(owner);
        uint256 finalAllowance = token.allowance(user, address(this));
        console.log("User balance:", userFinalBalance);
        console.log("Owner balance:", ownerFinalBalance);
        console.log("Allowance balance:", finalAllowance);
        
        // Validation logic
        uint256 userDiff = userInitialBalance - userFinalBalance;
        uint256 ownerDiff = ownerFinalBalance - ownerInitialBalance;
        uint256 allowanceDiff = initialAllowance - finalAllowance;
        
        bool userCorrect = userDiff == transferAmount;
        bool ownerCorrect = ownerDiff == transferAmount;
        bool allowanceCorrect = allowanceDiff == transferAmount;
        bool allCorrect = userCorrect && ownerCorrect && allowanceCorrect;
        
        console.log("User balance change: %s (%s)", 
            userDiff, 
            userCorrect ? "CORRECT" : "WRONG - Expected:30 ether");
        console.log("Owner balance change: %s (%s)", 
            ownerDiff, 
            ownerCorrect ? "CORRECT" : "WRONG - Expected:30 ether");
        console.log("Allowance change: %s (%s)", 
            allowanceDiff, 
            allowanceCorrect ? "CORRECT" : "WRONG - Expected:30 ether");
        
        // Vulnerability determination
        if (allCorrect) {
            console.log("Vulnerability not Exist: TransferFrom and allowance management function correctly");
        } else {
            console.log("Vulnerability Exists: State changes don't match transfer amount indicating flaw");
        }
    }
}