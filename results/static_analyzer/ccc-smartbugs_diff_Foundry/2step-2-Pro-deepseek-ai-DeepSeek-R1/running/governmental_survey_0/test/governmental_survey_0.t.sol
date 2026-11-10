// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/governmental_survey.sol";

contract MaliciousOwner {
    receive() external payable {
        revert("Block ETH receipts");
    }

    function invest(Governmental gov) external payable {
        gov.invest{value: 1 ether}();
    }
}

contract MaliciousInvestor {
    receive() external payable {
        revert("Reject payments");
    }
}

contract GovernmentalTest is Test {
    Governmental gov;
    MaliciousOwner maliciousOwner;
    MaliciousInvestor maliciousInvestor;
    address deployer = address(0xBEEF);
    uint256 constant JACKPOT = 1 ether;

    function setUp() public {
        vm.deal(deployer, 10 ether);
        vm.startPrank(deployer);
        gov = new Governmental{value: JACKPOT}();
        vm.stopPrank();

        maliciousOwner = new MaliciousOwner();
        maliciousInvestor = new MaliciousInvestor();
    }

    function test_resetInvestmentFailsSilentlyWhenInvestorTransferFails() public {
        // Fund malicious investor and make investment
        vm.deal(address(maliciousInvestor), JACKPOT);
        vm.prank(address(maliciousInvestor));
        gov.invest{value: JACKPOT}();

        // Verify investor state
        assertEq(gov.lastInvestor(), address(maliciousInvestor), "Investor not set");
        uint256 initialGovBalance = address(gov).balance;

        // Advance beyond cooldown
        vm.warp(block.timestamp + 61 seconds);

        console2.log("--- BEFORE-Trigger State ---");
        // Capture only essential state variables
        uint256 investorBalanceBefore = address(maliciousInvestor).balance;
        uint256 totalWinnersBefore = gov.totalWinners();
        uint256 investorWinsBefore = gov.investorWins(address(maliciousInvestor));
        
        console2.log("Contract balance (before):", initialGovBalance);
        console2.log("Deployer balance (before):", deployer.balance);
        console2.log("Investor balance (before):", investorBalanceBefore);
        console2.log("Last Investor (before):", gov.lastInvestor());
        console2.log("Jackpot (before):", gov.jackpot());
        console2.log("Total Winners (before):", totalWinnersBefore);
        console2.log("Investor Wins (before):", investorWinsBefore);

        console2.log("--- Trigger Operation: resetInvestment ---");
        address resetCaller = makeAddr("resetCaller");
        vm.prank(resetCaller);
        gov.resetInvestment();

        console2.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(gov).balance;
        uint256 investorBalanceAfter = address(maliciousInvestor).balance;
        uint256 totalWinnersAfter = gov.totalWinners();
        uint256 investorWinsAfter = gov.investorWins(address(maliciousInvestor));
        
        console2.log("Contract balance (after):", contractBalanceAfter);
        console2.log("Deployer balance (after):", deployer.balance);
        console2.log("Investor balance (after):", investorBalanceAfter);
        console2.log("Last Investor (after):", gov.lastInvestor());
        console2.log("Jackpot (after):", gov.jackpot());
        console2.log("Total Winners (after):", totalWinnersAfter);
        console2.log("Investor Wins (after):", investorWinsAfter);

        // Validate state reset
        assertEq(gov.lastInvestor(), address(0), "Investor not reset");
        assertEq(gov.jackpot(), JACKPOT, "Jackpot not reset");
        assertEq(totalWinnersAfter, totalWinnersBefore + 1, "Winner count not updated");
        assertEq(investorWinsAfter, investorWinsBefore + 1, "Investor win count not updated");
        
        // Verify balance transfer to owner succeeded despite investor failure
        uint256 ownerPayment = initialGovBalance - JACKPOT;
        assertEq(contractBalanceAfter, JACKPOT, "Gov balance mismatch");
        assertEq(deployer.balance, 10 ether - JACKPOT + ownerPayment, "Owner not paid correctly");

        // Vulnerability verdict based on state changes
        bool stateUpdated = (gov.lastInvestor() == address(0)) && 
                            (totalWinnersAfter == totalWinnersBefore + 1) &&
                            (investorWinsAfter == investorWinsBefore + 1);
        bool transferFailed = (investorBalanceAfter == investorBalanceBefore);
        
        if (stateUpdated && transferFailed) {
            console2.log("Vulnerability Exists: State updated despite failed ETH transfer to investor.");
        } else {
            console2.log("Vulnerability not Exist: State changes or transfers executed unexpectedly.");
        }
    }

    function test_withdrawFeesFailsSilentlyWhenOwnerTransferFails() public {
        // Deploy new gov with malicious owner
        vm.deal(address(maliciousOwner), JACKPOT);
        vm.prank(address(maliciousOwner));
        Governmental hostileGov = new Governmental{value: JACKPOT}();

        // Add fees to contract (balance > jackpot)
        uint256 feesAdded = 0.5 ether;
        vm.deal(address(hostileGov), JACKPOT + feesAdded);

        console2.log("--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = address(hostileGov).balance;
        uint256 ownerBalanceBefore = address(maliciousOwner).balance;
        
        console2.log("Contract balance (before):", contractBalanceBefore);
        console2.log("Owner balance (before):", ownerBalanceBefore);

        console2.log("--- Trigger Operation: withdrawFees ---");
        // Attempt withdrawal - will fail but event still emitted
        vm.expectEmit(address(hostileGov));
        emit Governmental.OwnerWithdrawal(address(maliciousOwner), feesAdded);
        
        vm.prank(address(maliciousOwner));
        hostileGov.withdrawFees();

        console2.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(hostileGov).balance;
        uint256 ownerBalanceAfter = address(maliciousOwner).balance;
        
        console2.log("Contract balance (after):", contractBalanceAfter);
        console2.log("Owner balance (after):", ownerBalanceAfter);

        // Verify state unchanged despite failed transfer
        assertEq(contractBalanceAfter, JACKPOT + feesAdded, "Fees withdrawn incorrectly");
        assertEq(ownerBalanceAfter, 0, "Malicious owner received funds");

        // Vulnerability verdict
        bool balanceUnchanged = (contractBalanceAfter == contractBalanceBefore) && 
                                (ownerBalanceAfter == ownerBalanceBefore);
        
        if (balanceUnchanged) {
            console2.log("Vulnerability Exists: Event emitted despite failed ETH transfer to owner.");
        } else {
            console2.log("Vulnerability not Exist: Balances changed unexpectedly.");
        }
    }
}