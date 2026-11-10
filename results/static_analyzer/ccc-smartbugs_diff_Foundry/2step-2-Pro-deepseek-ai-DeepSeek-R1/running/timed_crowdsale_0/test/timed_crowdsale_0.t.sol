// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "../src/timed_crowdsale.sol";
import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";

contract TimedCrowdsaleTest is Test {
    TimedCrowdsale public crowdsale;
    address public owner;
    address public contributor;

    uint256 public constant FINISH_TIMESTAMP = 1546300800;
    uint256 public constant ONE_DAY = 86400;
    uint256 public constant PRE_FINISH_TIME = FINISH_TIMESTAMP - 1;
    uint256 public contributionAmount = 1 ether;

    function uint2str(uint256 _value) internal pure returns (string memory) {
        if (_value == 0) return "0";
        uint256 temp = _value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (_value != 0) {
            digits--;
            buffer[digits] = bytes1(uint8(48 + _value % 10));
            _value /= 10;
        }
        return string(buffer);
    }

    function setUp() public {
        crowdsale = new TimedCrowdsale();
        owner = address(this); // Test contract is deployer/owner
        contributor = address(0x1);
        vm.deal(contributor, 10 ether);
    }

    // Add receive function to accept withdrawal transfers
    receive() external payable {}

    function test_timestampManipulation() public {
        // Advance to 1 second before finish time
        vm.warp(PRE_FINISH_TIME);
        assertFalse(crowdsale.isSaleFinished(), "Sale finished unexpectedly");

        // Store initial owner balance
        uint256 initialOwnerBalance = address(this).balance;

        // Contribute while sale is active
        vm.prank(contributor);
        crowdsale.contribute{value: contributionAmount}();
        assertEq(
            address(crowdsale).balance,
            contributionAmount,
            "Failed to capture contribution"
        );

        // Immediately attempt owner withdrawal (should fail)
        vm.expectRevert();
        crowdsale.withdrawFunds();

        // Advance time to finish timestamp
        vm.warp(FINISH_TIMESTAMP);
        assertTrue(crowdsale.isSaleFinished(), "Sale did not finish");

        // Owner withdrawals now possible
        crowdsale.withdrawFunds();
        assertEq(
            address(crowdsale).balance,
            0,
            "Failed to withdraw funds"
        );
        assertEq(
            address(this).balance,
            initialOwnerBalance + contributionAmount,
            "Owner did not receive funds"
        );

        // Attempt contribution after sale finish
        vm.prank(contributor);
        vm.expectRevert();
        crowdsale.contribute{value: contributionAmount}();
    }

    function test_boundaryTimestampControl() public {
        // Record initial state
        uint256 initialContractBalance = address(crowdsale).balance;
        uint256 initialContributorContribution = crowdsale.contributions(contributor);
        uint256 initialTotalContributions = crowdsale.totalContributions();
        
        console2.log("--- BEFORE-Trigger Warp Operations ---");
        console2.log("Contract Balance (initial):", uint2str(initialContractBalance));
        console2.log("Contributor Contribution (initial):", uint2str(initialContributorContribution));
        console2.log("Total Contributions (initial):", uint2str(initialTotalContributions));

        // Demonstrate control over boundary conditions
        console2.log("--- Trigger Warp Operations---");
        vm.warp(FINISH_TIMESTAMP - ONE_DAY);
        assertFalse(crowdsale.isSaleFinished(), "Sale finished too early");

        // Jump exactly to finish timestamp
        vm.warp(FINISH_TIMESTAMP);
        assertTrue(crowdsale.isSaleFinished(), "Sale didn't finish at exact time");

        // Jump even further to show control
        vm.warp(FINISH_TIMESTAMP + ONE_DAY);
        assertTrue(crowdsale.isSaleFinished(), "Sale didn't remain finished");

        // Record final state
        uint256 finalContractBalance = address(crowdsale).balance;
        uint256 finalContributorContribution = crowdsale.contributions(contributor);
        uint256 finalTotalContributions = crowdsale.totalContributions();
        
        console2.log("--- AFTER-Trigger Warp Operations ---");
        console2.log("Contract Balance (final):", uint2str(finalContractBalance));
        console2.log("Contributor Contribution (final):", uint2str(finalContributorContribution));
        console2.log("Total Contributions (final):", uint2str(finalTotalContributions));

        // Compare with initial state
        bool stateChanged = (finalContractBalance != initialContractBalance) ||
            (finalContributorContribution != initialContributorContribution) ||
            (finalTotalContributions != initialTotalContributions);

        if (stateChanged) {
            console2.log("Vulnerability Exists: Financial state altered during timestamp warp");
        } else {
            console2.log("Vulnerability not Exist: Contract state remains consistent during timestamp manipulation");
        }
        
        // Double-check consistency
        assertEq(finalContractBalance, initialContractBalance, "Contract balance changed during warp");
        assertEq(finalContributorContribution, initialContributorContribution, "Contributor contribution changed during warp");
        assertEq(finalTotalContributions, initialTotalContributions, "Total contributions changed during warp");
    }
}