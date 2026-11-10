// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/incorrect_constructor_name1.sol";

contract MissingTest is Test {
    Missing public missingContract;
    address owner = address(0x1);
    address attacker = address(0x2);

    function setUp() public {
        missingContract = new Missing();
    }

    function testAnyoneCanCallIamMissing() public {
        address newAttacker = address(0x3);

        // --- BEFORE-Trigger ---
        console.log("[PRE] Starting test: testAnyoneCanCallIamMissing");

        // --- Trigger: First attacker call ---
        console.log("[TRIGGER] Call IamMissing() by Attacker (0x2)");
        vm.prank(attacker);
        (bool success1, ) = address(missingContract).call(abi.encodeWithSignature("IamMissing()"));
        console.log("[POST-TRIGGER] First call result: %s", success1 ? "Success" : "Failure");

        // --- Trigger: Second attacker call ---
        console.log("[TRIGGER] Call IamMissing() by New Attacker (0x3)");
        vm.prank(newAttacker);
        (bool success2, ) = address(missingContract).call(abi.encodeWithSignature("IamMissing()"));
        console.log("[POST-TRIGGER] Second call result: %s", success2 ? "Success" : "Failure");

        // --- Verdict ---
        bool vulnerabilityExists = success1 && success2;
        console.log("Both calls successful? %s", vulnerabilityExists ? "YES" : "NO");
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Function can be called by any address");
        } else {
            console.log("Vulnerability not Exist: Function access is restricted");
        }
    }

    function testFunctionCanBeCalledMultipleTimes() public {
        address thirdCaller = address(0x4);

        // --- BEFORE-Trigger ---
        console.log("[PRE] Starting test: testFunctionCanBeCalledMultipleTimes");

        // --- Trigger: First call by owner ---
        console.log("[TRIGGER] First call by Owner (0x1)");
        vm.prank(owner);
        (bool success1, ) = address(missingContract).call(abi.encodeWithSignature("IamMissing()"));
        console.log("[POST-TRIGGER] First call result: %s", success1 ? "Success" : "Failure");

        // --- Trigger: Second call by attacker ---
        console.log("[TRIGGER] Second call by Attacker (0x2)");
        vm.prank(attacker);
        (bool success2, ) = address(missingContract).call(abi.encodeWithSignature("IamMissing()"));
        console.log("[POST-TRIGGER] Second call result: %s", success2 ? "Success" : "Failure");

        // --- Trigger: Third call by new address ---
        console.log("[TRIGGER] Third call by New Caller (0x4)");
        vm.prank(thirdCaller);
        (bool success3, ) = address(missingContract).call(abi.encodeWithSignature("IamMissing()"));
        console.log("[POST-TRIGGER] Third call result: %s", success3 ? "Success" : "Failure");

        // --- Verdict ---
        bool vulnerabilityExists = success1 && success2 && success3;
        console.log("All calls successful? %s", vulnerabilityExists ? "YES" : "NO");
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Function can be called multiple times");
        } else {
            console.log("Vulnerability not Exist: Function call restrictions exist");
        }
    }
}