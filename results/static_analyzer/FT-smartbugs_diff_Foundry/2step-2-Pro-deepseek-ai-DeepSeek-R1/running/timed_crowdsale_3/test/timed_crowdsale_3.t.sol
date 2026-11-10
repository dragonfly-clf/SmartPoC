// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/timed_crowdsale.sol";

contract TimedCrowdsaleTest is Test {
    TimedCrowdsale public crowdsale;
    address public owner = makeAddr("owner");
    address public contributor = makeAddr("contributor");
    uint256 public constant SALE_END = 1546300800;

    function setUp() public {
        vm.startPrank(owner);
        crowdsale = new TimedCrowdsale();
        vm.stopPrank();
        
        // Set time before sale ends
        vm.warp(SALE_END - 1 days);
    }

    function test_NoRefundMechanism() public {
        // Fund contributor and make contribution
        vm.deal(contributor, 1 ether);
        vm.prank(contributor);
        crowdsale.contribute{value: 1 ether}();

        // Advance time past sale end (without meeting funding goal)
        vm.warp(SALE_END + 1);

        // Verify sale has ended
        assertTrue(crowdsale.isSaleFinished(), "Sale should be finished");

        console2.log("--- BEFORE-Trigger RefundAttempt ---");
        uint256 initialContractBalance = address(crowdsale).balance;
        uint256 initialContributorBalance = contributor.balance;
        uint256 initialContributorRecord = crowdsale.contributions(contributor);
        uint256 initialTotalContributions = crowdsale.totalContributions();
        
        console2.log("Contract ETH Balance:", initialContractBalance);
        console2.log("Contributor ETH Balance:", initialContributorBalance);
        console2.log("Contributor's Record:", initialContributorRecord);
        console2.log("Total Contributions:", initialTotalContributions);

        console2.log("--- Trigger RefundAttempt ---");
        vm.prank(contributor);
        (bool success, ) = address(crowdsale).call(
            abi.encodeWithSignature("refund()")
        );

        console2.log("--- AFTER-Trigger RefundAttempt ---");
        uint256 afterContractBalance = address(crowdsale).balance;
        uint256 afterContributorBalance = contributor.balance;
        uint256 afterContributorRecord = crowdsale.contributions(contributor);
        uint256 afterTotalContributions = crowdsale.totalContributions();
        
        console2.log("Contract ETH Balance:", afterContractBalance);
        console2.log("Contributor ETH Balance:", afterContributorBalance);
        console2.log("Contributor's Record:", afterContributorRecord);
        console2.log("Total Contributions:", afterTotalContributions);

        // Verify refund attempt fails
        assertFalse(success, "Refund call should revert");

        // Check state changes
        bool contractBalanceUnchanged = afterContractBalance == initialContractBalance;
        bool contributorBalanceUnchanged = afterContributorBalance == initialContributorBalance;
        bool contribRecordUnchanged = afterContributorRecord == initialContributorRecord;
        bool totalContributionsUnchanged = afterTotalContributions == initialTotalContributions;
        bool stateUnchanged = contractBalanceUnchanged && 
                              contributorBalanceUnchanged && 
                              contribRecordUnchanged && 
                              totalContributionsUnchanged;
        
        console2.log("All state unchanged:", stateUnchanged);

        // Final vulnerability verification
        if (!success && stateUnchanged) {
            console2.log("Vulnerability Exists: Refund call failed and state unchanged, confirming missing refund mechanism");
        } else {
            console2.log("Vulnerability not Exist: Unexpected state change or successful refund");
        }
    }
}