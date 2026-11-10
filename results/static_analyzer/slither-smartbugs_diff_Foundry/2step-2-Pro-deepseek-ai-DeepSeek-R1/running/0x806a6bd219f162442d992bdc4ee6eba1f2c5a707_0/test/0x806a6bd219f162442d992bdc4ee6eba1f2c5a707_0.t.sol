// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x806a6bd219f162442d992bdc4ee6eba1f2c5a707.sol";

contract PieTest is Test {
    Pie public pie;
    address player = makeAddr("player");
    
    // Allows the test contract to receive ether transfers
    receive() external payable {}

    function setUp() public {
        pie = new Pie();
        vm.deal(address(pie), 5 ether); // Seed contract with 5 ether
        vm.deal(player, 10 ether);       // Fund player
    }

    function testGetPieVulnerability() public {
        // Record initial state
        console.log("--- BEFORE-Trigger State ---");
        uint256 preOwnerBalance = address(this).balance;
        uint256 prePlayerBalance = player.balance;
        uint256 prePieBalance = address(pie).balance;
        console.log("Owner balance:      ", preOwnerBalance);
        console.log("Player balance:     ", prePlayerBalance);
        console.log("Pie contract balance: ", prePieBalance);
        
        console.log("--- Trigger Action: Player calls GetPie(1.1 ether) ---");
        // Execute the exploit
        vm.prank(player);
        pie.GetPie{value: 1.1 ether}();
        
        // Record final state
        console.log("--- AFTER-Trigger State ---");
        uint256 postOwnerBalance = address(this).balance;
        uint256 postPlayerBalance = player.balance;
        uint256 postPieBalance = address(pie).balance;
        console.log("Owner balance:      ", postOwnerBalance);
        console.log("Player balance:     ", postPlayerBalance);
        console.log("Pie contract balance: ", postPieBalance);
        
        // Calculate state changes
        uint256 ownerBalanceChange = postOwnerBalance - preOwnerBalance;
        uint256 playerBalanceChange = prePlayerBalance - postPlayerBalance;
        uint256 pieBalanceChange = prePieBalance - postPieBalance;
        
        uint256 expectedOwnerBalanceChange = prePieBalance + 1.1 ether;
        
        console.log("State Changes Analysis:");
        console.log("Owner balance change (actual vs expected): ", 
            ownerBalanceChange, "==", expectedOwnerBalanceChange);
        console.log("Player balance change (expected 1.1 ether):", playerBalanceChange);
        console.log("Pie balance change (expected full balance):", pieBalanceChange);
        
        // Vulnerability conditions
        bool contractDrained = (postPieBalance == 0);
        bool ownerGainedCorrectly = (ownerBalanceChange == expectedOwnerBalanceChange);
        bool playerLostCorrectly = (playerBalanceChange == 1.1 ether);
        
        // Final verdict
        if (contractDrained && ownerGainedCorrectly && playerLostCorrectly) {
            console.log("Vulnerability Exists: All exploit conditions met");
        } else {
            console.log("Vulnerability not Exist: Failed conditions -");
            if (!contractDrained) console.log("- Contract not drained (%s left)", postPieBalance);
            if (!ownerGainedCorrectly) console.log("- Owner gain mismatch (actual %s vs expected %s)", 
                ownerBalanceChange, expectedOwnerBalanceChange);
            if (!playerLostCorrectly) console.log("- Player loss mismatch (actual %s vs expected 1.1 ether)", 
                playerBalanceChange);
        }
    }
}