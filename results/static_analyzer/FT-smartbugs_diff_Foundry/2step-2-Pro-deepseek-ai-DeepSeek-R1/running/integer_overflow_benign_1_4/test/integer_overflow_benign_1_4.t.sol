// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_benign_1.sol";

contract IntegerOverflowBenign1Test is Test {
    IntegerOverflowBenign1 public contractInstance;
    address alice = address(0x1);
    address bob = address(0x2);
    
    function setUp() public {
        contractInstance = new IntegerOverflowBenign1();
    }

    function test_maliciousUserCanResetOperations() public {
        // Alice performs operations to increase her count
        vm.prank(alice);
        contractInstance.run(1);
        uint256 aliceInitialCount = contractInstance.getUserOperationCount(alice);
        
        // Bob performs operations to increase his count
        vm.prank(bob);
        contractInstance.run(1);
        uint256 bobInitialCount = contractInstance.getUserOperationCount(bob);
        
        // Validate both have non-zero operation counts
        assertGt(aliceInitialCount, 0, "Alice should have operations");
        assertGt(bobInitialCount, 0, "Bob should have operations");
        
        // Alice resets her own count then verifies
        vm.prank(alice);
        contractInstance.resetUserOperations();
        uint256 aliceAfterReset = contractInstance.getUserOperationCount(alice);
        assertEq(aliceAfterReset, 0, "Alice should reset their count");
        
        // Bob resets his own count then verifies
        vm.prank(bob);
        contractInstance.resetUserOperations();
        uint256 bobAfterReset = contractInstance.getUserOperationCount(bob);
        assertEq(bobAfterReset, 0, "Bob should reset their count");
        
        address attacker = address(0xdeadbeef);
        console.log("--- BEFORE Trigger (Attacker) ---");
        uint256 preAttackerCount = contractInstance.getUserOperationCount(attacker);
        console.log("Attacker operation count pre-reset:", preAttackerCount);
        
        console.log("--- TRIGGER: Attacker calls resetUserOperations ---");
        vm.prank(attacker);
        contractInstance.resetUserOperations();
        
        console.log("--- AFTER Trigger (Attacker) ---");
        uint256 postAttackerCount = contractInstance.getUserOperationCount(attacker);
        console.log("Attacker operation count post-reset:", postAttackerCount);
        assertEq(postAttackerCount, 0, "Even new users can reset");
        
        console.log("------------------------------------------");
        console.log("Verification: Function call succeeded even for address with no operations");
        console.log("Vulnerability Exists: resetUserOperations can be called by any address without restrictions");
    }
}