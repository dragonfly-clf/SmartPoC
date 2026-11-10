// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/lottery.sol";

contract LotteryDestroyTest is Test {
    Lottery lottery;
    address organizer = makeAddr("organizer");
    address player = makeAddr("player");

    function setUp() public {
        // Deploy lottery as organizer
        vm.startPrank(organizer);
        lottery = new Lottery();
        vm.stopPrank();
        
        // Fund player for betting
        vm.deal(player, 1 ether);
    }

    function test_destroyWithActiveBets() public {
        // Player makes a bet
        vm.prank(player);
        lottery.makeBet{value: 1 ether}();

        // Verify funds are locked in contract
        assertEq(address(lottery).balance, 1 ether, "Contract should hold player funds");
        
        console2.log("--- BEFORE-Trigger Destroy ---");
        // Record balances before destruction
        uint256 contractBalanceBefore = address(lottery).balance;
        uint256 organizerBalanceBefore = organizer.balance;
        console2.log("Contract balance before:", contractBalanceBefore);
        console2.log("Organizer balance before:", organizerBalanceBefore);
        
        console2.log("--- Trigger Destroy ---");
        // Organizer destroys contract
        vm.prank(organizer);
        lottery.destroy();
        
        console2.log("--- AFTER-Trigger Destroy ---");
        // Record balances after destruction
        uint256 contractBalanceAfter = address(lottery).balance;
        uint256 organizerBalanceAfter = organizer.balance;
        console2.log("Contract balance after:", contractBalanceAfter);
        console2.log("Organizer balance after:", organizerBalanceAfter);

        // Calculate changes
        uint256 contractBalanceChange = contractBalanceBefore - contractBalanceAfter;
        uint256 organizerBalanceChange = organizerBalanceAfter - organizerBalanceBefore;
        console2.log("Contract balance change:", contractBalanceChange);
        console2.log("Organizer balance change:", organizerBalanceChange);
        
        // Differential validation
        bool fundsTransferred = (contractBalanceBefore == contractBalanceChange) &&
                               (organizerBalanceChange == contractBalanceBefore);
        bool contractDestroyed = contractBalanceAfter == 0;
        
        bool vulnExists = fundsTransferred && contractDestroyed;
        
        // Final vulnerability verdict
        if (vulnExists) {
            console2.log("Vulnerability Exists: Organizer can steal funds by destroying contract");
        } else {
            console2.log("Vulnerability not Exist: Funds were not transferred upon destruction");
        }
    }
}