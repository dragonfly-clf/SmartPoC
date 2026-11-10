// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/EKARTINU.sol";

contract EKARTINUEventTest is Test {
    EKARTINU token;
    address owner;
    address admin;
    address user = address(0x123);

    function setUp() public {
        owner = address(this);
        token = new EKARTINU();
        admin = token.owner();
    }

    /// @notice Differential validation for the "missing event emission" vulnerability.
    /// The bug is NOT a change in a storage value, so the differential state we query
    /// is the event-log buffer:
    ///   BEFORE  -> start recording (buffer is empty; a legit admin setter should append >=1 log)
    ///   TRIGGER -> perform the admin action (it succeeds => state really changed)
    ///   AFTER   -> collect logs and count them
    ///   COMPARE -> expected >=1 event, if we get 0 the event is missing => vulnerable
    function test_noEventsForAdminFunctions() public {
        uint256 missingEventCount = 0;
        Vm.Log[] memory logs;

        // =====================================================================
        // Operation 1: excludeFromFee(user)
        // =====================================================================
        console.log("============================================================");
        console.log("[Operation 1] excludeFromFee(user)");
        console.log("(i)  BEFORE-Trigger: log buffer empty, event recording STARTED; expect >= 1 event for a state-changing admin setter");
        vm.recordLogs();
        console.log("(ii) TRIGGER: admin calls excludeFromFee(user) (succeeds => state really changes)");
        vm.prank(admin);
        token.excludeFromFee(user);
        logs = vm.getRecordedLogs();
        console.log("(iii) AFTER-Trigger: events emitted =", logs.length);
        if (logs.length == 0) {
            console.log("(iv) COMPARISON: expected >= 1 event, observed 0 -> EVENT MISSING (vulnerable)");
            missingEventCount++;
        } else {
            console.log("(iv) COMPARISON: event emitted -> not vulnerable for this action");
        }

        // =====================================================================
        // Operation 2: includeInFee(user)
        // =====================================================================
        console.log("============================================================");
        console.log("[Operation 2] includeInFee(user)");
        // setup only (not measured): ensure user is currently excluded
        vm.prank(admin);
        token.excludeFromFee(user);
        console.log("(i)  BEFORE-Trigger: log buffer empty, event recording STARTED; expect >= 1 event for a state-changing admin setter");
        vm.recordLogs();
        console.log("(ii) TRIGGER: admin calls includeInFee(user) (succeeds => state really changes)");
        vm.prank(admin);
        token.includeInFee(user);
        logs = vm.getRecordedLogs();
        console.log("(iii) AFTER-Trigger: events emitted =", logs.length);
        if (logs.length == 0) {
            console.log("(iv) COMPARISON: expected >= 1 event, observed 0 -> EVENT MISSING (vulnerable)");
            missingEventCount++;
        } else {
            console.log("(iv) COMPARISON: event emitted -> not vulnerable for this action");
        }

        // =====================================================================
        // Operation 3: setLiquidityFee(100)
        // =====================================================================
        console.log("============================================================");
        console.log("[Operation 3] setLiquidityFee(100)");
        console.log("(i)  BEFORE-Trigger: log buffer empty, event recording STARTED; expect >= 1 event for a state-changing admin setter");
        vm.recordLogs();
        console.log("(ii) TRIGGER: admin calls setLiquidityFee(100) (succeeds => fee state really changes)");
        vm.prank(admin);
        token.setLiquidityFee(100);
        logs = vm.getRecordedLogs();
        console.log("(iii) AFTER-Trigger: events emitted =", logs.length);
        if (logs.length == 0) {
            console.log("(iv) COMPARISON: expected >= 1 event, observed 0 -> EVENT MISSING (vulnerable)");
            missingEventCount++;
        } else {
            console.log("(iv) COMPARISON: event emitted -> not vulnerable for this action");
        }

        // =====================================================================
        // Operation 4: setCovidFee(100)
        // =====================================================================
        console.log("============================================================");
        console.log("[Operation 4] setCovidFee(100)");
        console.log("(i)  BEFORE-Trigger: log buffer empty, event recording STARTED; expect >= 1 event for a state-changing admin setter");
        vm.recordLogs();
        console.log("(ii) TRIGGER: admin calls setCovidFee(100) (succeeds => fee state really changes)");
        vm.prank(admin);
        token.setCovidFee(100);
        logs = vm.getRecordedLogs();
        console.log("(iii) AFTER-Trigger: events emitted =", logs.length);
        if (logs.length == 0) {
            console.log("(iv) COMPARISON: expected >= 1 event, observed 0 -> EVENT MISSING (vulnerable)");
            missingEventCount++;
        } else {
            console.log("(iv) COMPARISON: event emitted -> not vulnerable for this action");
        }

        // =====================================================================
        // FINAL VERDICT (exactly one line)
        // =====================================================================
        console.log("============================================================");
        console.log("Summary: admin actions missing expected events =", missingEventCount, "/ 4");
        if (missingEventCount == 4) {
            console.log("Vulnerability Exists: excludeFromFee/includeInFee/setLiquidityFee/setCovidFee all mutate critical state without emitting any event, so off-chain monitors cannot observe these admin changes");
        } else {
            console.log("Vulnerability not Exist: at least one admin action emitted the expected event");
        }
    }
}