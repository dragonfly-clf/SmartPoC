// SPDX-License-Identifier: MIT
pragma solidity 0.8.2;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract CoinTokenBurnTest is Test {
    CoinToken token;
    address owner = address(0xA);
    address alice = address(0xB);
    uint256 initialSupply = 1000 ether; // 1000 tokens accounting for 18 decimals

    function setUp() public {
        vm.startPrank(owner);
        token = new CoinToken(
            "VulnerableToken",
            "VULN",
            18,             // decimals
            1000,           // token supply (1000 * 10^18)
            0,              // txFee
            0,              // burnFee
            0,              // charityFee
            address(0),     // charity address
            owner           // initial token holder
        );
        vm.stopPrank();
    }

    function testBurnCausesDivisionByZero() public {
        // Owner burns entire token supply
        console.log("--- BEFORE-Trigger Burn ---");
        uint256 initialBalance = token.balanceOf(owner);
        console.log("Owner initial balance:", initialBalance);

        console.log("--- Trigger Burn ---");
        vm.startPrank(owner);
        token.burn(initialSupply);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Burn ---");
        console.log("Attempting balanceOf(owner) call - should revert");
        
        vm.expectRevert("SafeMath: division by zero");
        token.balanceOf(owner);
        
        console.log("Vulnerability Exists: Burn operation caused division by zero in reflection calculations");
    }

    function testMintDoesNotConvertCorrectly() public {
        uint256 amount = 100 ether;
        
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 initialRate = token.reflectionFromToken(1 ether, false) / (1 ether);
        console.log("Initial reflection rate:", initialRate);
        uint256 expectedMintedReflection = amount * initialRate;
        console.log("Expected reflections for minted tokens:", expectedMintedReflection);

        console.log("--- Trigger Mint ---");
        vm.prank(owner);
        token.mint(owner, amount);

        console.log("--- AFTER-Trigger Mint ---");
        uint256 actualMintedReflection = token.reflectionFromToken(amount, false);
        console.log("Actual reflections for minted tokens:", actualMintedReflection);
        
        bool isVulnerable = actualMintedReflection < expectedMintedReflection;
        if (isVulnerable) {
            console.log("Vulnerability Exists: Actual minted reflections less than expected");
        } else {
            console.log("Vulnerability not Exist: Minted reflections match expected value");
        }
        
        // Maintain original assertion
        assertLt(actualMintedReflection, expectedMintedReflection);
    }
}