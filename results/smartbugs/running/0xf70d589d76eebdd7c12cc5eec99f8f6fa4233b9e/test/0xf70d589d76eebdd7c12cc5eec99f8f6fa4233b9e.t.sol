// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xf70d589d76eebdd7c12cc5eec99f8f6fa4233b9e.sol";

contract WhaleGiveaway2Test is Test {
    WhaleGiveaway2 giveaway;
    address owner = address(0x1);
    address attacker = address(0x2);
    
    // Use a higher address to avoid precompile conflicts
    address failingContract = address(0x123456789);

    function setUp() public {
        vm.startPrank(owner);
        giveaway = new WhaleGiveaway2();
        vm.deal(owner, 1 ether);
        vm.stopPrank();
    }

    function testUncheckedCallVulnerability() public {
        // Create a contract that will fail when receiving ETH
        vm.etch(failingContract, hex"00");
        
        console2.log("--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = address(giveaway).balance;
        uint256 targetBalanceBefore = address(failingContract).balance;
        console2.log("Contract balance before:", contractBalanceBefore);
        console2.log("Failing contract balance before:", targetBalanceBefore);

        console2.log("--- Trigger Command to failing contract ---");
        // Owner sends ETH to failing contract through Command function
        vm.prank(owner);
        bytes memory data;
        giveaway.Command{value: 1 ether}(failingContract, data);

        console2.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(giveaway).balance;
        uint256 targetBalanceAfter = address(failingContract).balance;
        console2.log("Contract balance after:", contractBalanceAfter);
        console2.log("Failing contract balance after:", targetBalanceAfter);
        
        bool fundsStuck = (contractBalanceAfter == 1 ether) && 
                          (targetBalanceAfter == 0);
        bool vulnerabilityExploited = fundsStuck;
        
        if (vulnerabilityExploited) {
            console2.log("Vulnerability Exists: Contract balance increased by 1 ether but failing contract received 0 ether");
            console2.log("Vulnerability Exists: Unchecked low-level call allows loss of funds");
        } else {
            console2.log("Vulnerability not Exist: Funds were properly transferred or preserved");
        }
    }

    function testSuccessfulCallForComparison() public {
        // Send to a regular address to show proper behavior
        address recipient = address(0x4);
        uint256 initialBalance = recipient.balance;
        uint256 contractBalanceBefore = address(giveaway).balance;

        vm.prank(owner);
        bytes memory data;
        giveaway.Command{value: 1 ether}(recipient, data);

        uint256 contractBalanceAfter = address(giveaway).balance;
        bool properTransfer = recipient.balance == initialBalance + 1 ether && 
                             contractBalanceAfter == contractBalanceBefore;
        
        assertTrue(properTransfer, "ETH should be transferred successfully and contract balance unchanged");
    }
}