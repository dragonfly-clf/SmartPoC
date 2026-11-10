// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MetaeggDeFi.sol";

contract MetaeggDeFiTest is Test {
    MetaeggDeFi token;
    address owner = address(0x1);
    address user = address(0x2);
    uint256 initialSupply;

    function setUp() public {
        vm.startPrank(owner);
        token = new MetaeggDeFi();
        vm.stopPrank();
        
        initialSupply = token.totalSupply();
    }

    function testCriticalMintingVulnerability() public {
        uint256 largeMintAmount = 1_000_000 * 10**18;
        
        // === First Mint ===
        console.log("--- BEFORE-Trigger First Mint ---");
        uint256 preSupply1 = token.totalSupply();
        uint256 preOwnerBalance1 = token.balanceOf(owner);
        console.log("Pre-Mint Total Supply: ", preSupply1);
        console.log("Pre-Mint Owner Balance: ", preOwnerBalance1);

        console.log("--- Trigger First Mint ---");
        vm.prank(owner);
        token.mint(largeMintAmount);
        
        console.log("--- AFTER-Trigger First Mint ---");
        uint256 postSupply1 = token.totalSupply();
        uint256 postOwnerBalance1 = token.balanceOf(owner);
        console.log("Post-Mint Total Supply: ", postSupply1);
        console.log("Post-Mint Owner Balance: ", postOwnerBalance1);
        
        // Verify first mint results
        uint256 expectedSupplyFirst = initialSupply + largeMintAmount;
        uint256 expectedBalanceFirst = preOwnerBalance1 + largeMintAmount;
        bool supplyGoodFirst = (postSupply1 == expectedSupplyFirst);
        bool balanceGoodFirst = (postOwnerBalance1 == expectedBalanceFirst);
        console.log("First Mint - Supply Check: ", supplyGoodFirst ? "PASS" : "FAIL");
        console.log("First Mint - Balance Check: ", balanceGoodFirst ? "PASS" : "FAIL");

        // === Second Mint ===
        console.log("--- BEFORE-Trigger Second Mint ---");
        uint256 preSupply2 = token.totalSupply();
        uint256 preOwnerBalance2 = token.balanceOf(owner);
        console.log("Pre-Mint Total Supply: ", preSupply2);
        console.log("Pre-Mint Owner Balance: ", preOwnerBalance2);

        console.log("--- Trigger Second Mint ---");
        vm.prank(owner);
        token.mint(largeMintAmount);
        
        console.log("--- AFTER-Trigger Second Mint ---");
        uint256 finalSupply = token.totalSupply();
        uint256 finalOwnerBalance = token.balanceOf(owner);
        console.log("Final Total Supply: ", finalSupply);
        console.log("Final Owner Balance: ", finalOwnerBalance);
        
        // Verify second mint results
        uint256 expectedSupplySecond = initialSupply + largeMintAmount * 2;
        uint256 expectedBalanceSecond = preOwnerBalance2 + largeMintAmount;
        bool supplyGoodSecond = (finalSupply == expectedSupplySecond);
        bool balanceGoodSecond = (finalOwnerBalance == expectedBalanceSecond);
        console.log("Second Mint - Supply Check: ", supplyGoodSecond ? "PASS" : "FAIL");
        console.log("Second Mint - Balance Check: ", balanceGoodSecond ? "PASS" : "FAIL");

        // Vulnerability confirmation
        console.log("--- VULNERABILITY VERDICT ---");
        if (supplyGoodFirst && balanceGoodFirst && supplyGoodSecond && balanceGoodSecond) {
            console.log("Vulnerability Exists: Owner can mint unlimited tokens leading to uncontrolled inflation");
        } else {
            console.log("Vulnerability not Exist: Token supply changes do not match expected mint amounts");
        }
    }

    function testNonOwnerCannotMint() public {
        uint256 mintAmount = 100 * 10**18;
        vm.prank(user);
        vm.expectRevert("Ownable: caller is not the owner");
        token.mint(mintAmount);
    }
}