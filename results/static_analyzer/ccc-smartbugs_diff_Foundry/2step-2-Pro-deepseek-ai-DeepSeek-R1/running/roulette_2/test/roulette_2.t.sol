// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/roulette.sol";

contract RouletteTest is Test {
    Roulette public roulette;
    
    // Test addresses
    address user1 = address(1);
    address user2 = address(2);
    
    function setUp() public {
        roulette = new Roulette();
        vm.deal(user1, 10 ether);
        vm.deal(user2, 10 ether);
    }
    
    function test_denialOfServiceSameBlock() public {
        // Warp to a fixed timestamp to simulate same-block execution
        vm.warp(1000);
        
        console.log("--- BEFORE-Trigger First Bet ---");
        console.log("First bet placed (expected successful)");
        vm.prank(user1);
        roulette.placeBet{value: 10 ether}();
        console.log("First bet successfully executed without revert");
        
        console.log("--- Trigger Second Bet ---");
        console.log("Attempting second bet in same block (should revert)");
        vm.prank(user2);
        vm.expectRevert("Only one bet per block allowed");
        roulette.placeBet{value: 10 ether}();
        
        console.log("--- AFTER-Trigger Result ---");
        console.log("Second bet reverted as expected");
        console.log("Vulnerability Exists: Second bet reverted due to same-block DoS protection");
    }
}