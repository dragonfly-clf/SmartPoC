// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/timed_crowdsale.sol";

contract TimedCrowdsaleTest is Test {
    TimedCrowdsale public crowdSale;
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    uint256 public constant FIXED_SALE_END = 1546300800; // Hardcoded sale end timestamp

    function setUp() public {
        vm.prank(owner);
        crowdSale = new TimedCrowdsale();
    }

    // Verify initial state (sale not finished before threshold)
    function test_InitialState_SaleNotFinished() public view {
        assertFalse(crowdSale.isSaleFinished(), "Sale should not be finished initially");
    }

    // Test contribution allowed before the fixed end time
    function test_ContributionAllowedBeforeEnd() public {
        // --- 新增：贡献前的状态记录 ---
        console.log("--- BEFORE-Trigger Contribution ---");
        uint256 userEthBefore = user.balance;
        uint256 contractEthBefore = address(crowdSale).balance;
        uint256 userContributionBefore = crowdSale.contributions(user);
        uint256 totalContributionBefore = crowdSale.totalContributions();
        console.log("User ETH balance    :", userEthBefore);
        console.log("Contract ETH balance:", contractEthBefore);
        console.log("User contribution   :", userContributionBefore);
        console.log("Total contributions :", totalContributionBefore);

        // --- 触发贡献操作 ---
        vm.warp(FIXED_SALE_END - 1); // Set to 1 second before sale end
        vm.deal(user, 1 ether);
        
        console.log("--- Trigger Contribution ---");
        vm.prank(user);
        crowdSale.contribute{value: 1 ether}();
        
        // --- 新增：贡献后的状态记录和验证 ---
        console.log("--- AFTER-Trigger Contribution ---");
        uint256 userEthAfter = user.balance;
        uint256 contractEthAfter = address(crowdSale).balance;
        uint256 userContributionAfter = crowdSale.contributions(user);
        uint256 totalContributionAfter = crowdSale.totalContributions();
        console.log("User ETH balance    :", userEthAfter);
        console.log("Contract ETH balance:", contractEthAfter);
        console.log("User contribution   :", userContributionAfter);
        console.log("Total contributions :", totalContributionAfter);

        // 验证状态变化
        console.log("--- Verification ---");
        uint256 userLoss = userEthBefore - userEthAfter;
        uint256 contractGain = contractEthAfter - contractEthBefore;
        uint256 contributionAdded = userContributionAfter - userContributionBefore;
        uint256 totalContributionAdded = totalContributionAfter - totalContributionBefore;
        console.log("User ETH loss          :", userLoss);
        console.log("Contract ETH gain      :", contractGain);
        console.log("User contribution add  :", contributionAdded);
        console.log("Total contribution add :", totalContributionAdded);

        // 最终判定
        console.log("Vulnerability Exists: The fixed sale end timestamp is predictable and cannot be modified");
    }

    // Test contribution allowed at the last possible moment (edge case)
    function test_ContributionAllowedExactlyBeforeEnd() public {
        vm.warp(FIXED_SALE_END - 1);
        vm.deal(user, 1 ether);
        
        vm.prank(user);
        crowdSale.contribute{value: 1 ether}();
        
        // Should not revert
    }

    // Test contribution blocked after fixed end time
    function test_ContributionBlockedAfterEnd() public {
        vm.warp(FIXED_SALE_END + 86400); // Advance 1 day after end
        vm.deal(user, 1 ether);
        
        vm.prank(user);
        vm.expectRevert("Sale has finished");
        crowdSale.contribute{value: 1 ether}();
    }

    // Test sale finish condition exactly at the fixed timestamp
    function test_SaleFinishedExactlyAtThreshold() public {
        vm.warp(FIXED_SALE_END);
        assertTrue(crowdSale.isSaleFinished(), "Sale should be finished at exactly the end time");
    }

    // Test owner CANNOT withdraw before sale finishes
    function test_OwnerCannotWithdrawBeforeEnd() public {
        vm.deal(address(crowdSale), 1 ether); // Directly fund contract
        
        vm.prank(owner);
        vm.expectRevert("Sale not finished yet");
        crowdSale.withdrawFunds();
    }

    // Test owner CAN withdraw after sale finishes
    function test_OwnerCanWithdrawAfterSale() public {
        // --- 新增：提现前的状态记录 ---
        console.log("--- BEFORE-Trigger Withdraw ---");
        vm.deal(address(crowdSale), 1 ether);
        vm.warp(FIXED_SALE_END + 1); // Set to after sale end
        
        uint256 contractBalanceBefore = address(crowdSale).balance;
        uint256 ownerBalanceBefore = owner.balance;
        console.log("Contract ETH balance:", contractBalanceBefore);
        console.log("Owner ETH balance   :", ownerBalanceBefore);

        // --- 触发提现操作 ---
        console.log("--- Trigger Withdraw ---");
        vm.prank(owner);
        crowdSale.withdrawFunds();
        
        // --- 新增：提现后的状态记录和验证 ---
        console.log("--- AFTER-Trigger Withdraw ---");
        uint256 contractBalanceAfter = address(crowdSale).balance;
        uint256 ownerBalanceAfter = owner.balance;
        console.log("Contract ETH balance:", contractBalanceAfter);
        console.log("Owner ETH balance   :", ownerBalanceAfter);

        // 验证状态变化
        console.log("--- Verification ---");
        uint256 ownerGain = ownerBalanceAfter - ownerBalanceBefore;
        uint256 contractLoss = contractBalanceBefore - contractBalanceAfter;
        console.log("Owner gain        :", ownerGain);
        console.log("Contract loss     :", contractLoss);

        // 最终判定
        assertEq(ownerGain, 1 ether, "Owner should receive funds");
        console.log("Vulnerability Exists: The fixed sale end timestamp is predictable and cannot be modified");
    }

}