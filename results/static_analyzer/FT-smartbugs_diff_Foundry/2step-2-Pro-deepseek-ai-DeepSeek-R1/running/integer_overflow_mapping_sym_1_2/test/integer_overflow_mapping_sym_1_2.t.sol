// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol"; // Added console2 import
import "../src/integer_overflow_mapping_sym_1.sol";

contract IntegerOverflowMappingSym1Test is Test {
    IntegerOverflowMappingSym1 public overflowContract;
    address public user = makeAddr("user");
    uint256 public key = 123;
    uint256 public subtractValue = 100;

    function setUp() public {
        overflowContract = new IntegerOverflowMappingSym1();
    }

    function test_IntegerUnderflow() public {
        // Pre-trigger state checks
        console2.log("--- BEFORE-Trigger State ---");
        uint256 initialMapValue = overflowContract.getMapValue(key);
        uint256 initialUserOps = overflowContract.getUserOperationCount(user);
        console2.log("Initial map value:", initialMapValue);
        console2.log("Initial user ops count:", initialUserOps);

        // Calculate expected underflow value
        uint256 expectedMapValue;
        unchecked {
            expectedMapValue = initialMapValue - subtractValue;
        }
        console2.log("Expected underflow value:", expectedMapValue);

        // Execute trigger action
        console2.log("--- Trigger Underflow ---");
        vm.prank(user);
        overflowContract.init(key, subtractValue);

        // Post-trigger state checks
        console2.log("--- AFTER-Trigger State ---");
        uint256 newMapValue = overflowContract.getMapValue(key);
        uint256 newUserOps = overflowContract.getUserOperationCount(user);
        console2.log("New map value:", newMapValue);
        console2.log("New user ops count:", newUserOps);

        // Validation and final verdict
        bool underflowVerified = newMapValue == expectedMapValue;
        bool opsUpdated = newUserOps == initialUserOps + 1;
        
        if (underflowVerified && opsUpdated) {
            console2.log("Vulnerability Exists: Integer underflow occurred in mapping and operation count updated");
        } else {
            console2.log("Vulnerability not Exist: Underflow not detected or operation count mismatch");
        }
    }
}