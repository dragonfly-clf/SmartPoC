// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_benign_1.sol";

contract IntegerOverflowBenign1Test is Test {
    IntegerOverflowBenign1 public opsManager;
    address public miner = address(0x1);
    address public victim = address(0x2);

    function setUp() public {
        opsManager = new IntegerOverflowBenign1();
        
        // Initialize operations for both addresses
        vm.startPrank(victim);
        opsManager.run(5);  // Create some operations for victim
        vm.stopPrank();
        
        vm.startPrank(miner);
        opsManager.run(3);  // Create some operations for miner
        vm.stopPrank();
    }

    function test_MinerCanFrontRunUserOperations() public {
        // Victim's initial operation count should be non-zero
        uint initialVictimCount = opsManager.getUserOperationCount(victim);
        assertGt(initialVictimCount, 0, "Victim should have operations");
        
        // Miner's initial operation count should be non-zero
        uint initialMinerCount = opsManager.getUserOperationCount(miner);
        assertGt(initialMinerCount, 0, "Miner should have operations");
        
        // Differential validation: capture state BEFORE trigger
        console2.log("--- BEFORE-Trigger UserOperationCount ---");
        uint minerOperationsBefore = opsManager.getUserOperationCount(miner);
        uint victimOperationsBefore = opsManager.getUserOperationCount(victim);
        console2.log("Miner operations:", minerOperationsBefore);
        console2.log("Victim operations:", victimOperationsBefore);

        console2.log("--- Trigger: Miner calls resetUserOperations ---");
        // Miner front-runs victim's transaction
        vm.prank(miner);
        opsManager.resetUserOperations(); // Miner uses victim's input (same function call)
        
        // Differential validation: capture state AFTER trigger
        console2.log("--- AFTER-Trigger UserOperationCount ---");
        uint minerOperationsAfter = opsManager.getUserOperationCount(miner);
        uint victimOperationsAfter = opsManager.getUserOperationCount(victim);
        console2.log("Miner operations:", minerOperationsAfter);
        console2.log("Victim operations:", victimOperationsAfter);
        
        // Verify miner's operations were reset
        uint minerCount = opsManager.getUserOperationCount(miner);
        assertEq(minerCount, 0, "Miner operations should be reset");
        
        // Verify victim's operations remain unchanged
        uint victimCount = opsManager.getUserOperationCount(victim);
        assertEq(victimCount, initialVictimCount, "Victim operations should remain");
        
        // Final verdict based on state changes
        if (victimOperationsAfter != victimOperationsBefore) {
            console2.log("Vulnerability Exists: Victim operations changed unexpectedly");
        } else if (minerOperationsAfter != 0) {
            console2.log("Vulnerability Exists: Miner operations not reset");
        } else {
            console2.log("Vulnerability not Exist: Only miner operations reset, victim unchanged");
        }
    }
}