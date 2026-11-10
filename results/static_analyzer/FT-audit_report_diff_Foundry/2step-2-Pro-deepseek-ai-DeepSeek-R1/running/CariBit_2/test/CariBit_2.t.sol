// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CariBit.sol";

// Mock implementation of PinkAntiBot to be deployed at fixed address
contract PinkAntiBotMock {
    function setTokenOwner(address) external {}
    function onPreTransferCheck(address, address, uint256) external {}
}

contract CaribitFeeTest is Test {
    CariBit token;
    address constant OWNER = address(0x1);
    address constant PINK_ANTI_BOT_ADDR = 0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002;

    function setUp() public {
        // Create runtime bytecode for PinkAntiBotMock
        bytes memory mockCode = type(PinkAntiBotMock).runtimeCode;
        
        // Deploy mock to fixed address using cheatcode
        vm.etch(PINK_ANTI_BOT_ADDR, mockCode);

        vm.startPrank(OWNER);
        token = new CariBit();
        token.setEnableAntiBot(false); // Disable anti-bot for test simplicity
        vm.stopPrank();
    }

    function testFeeManipulation() public {
        console.log("--- BEFORE-Trigger Fee Settings ---");
        // Query initial fees state
        uint256 preBNB = token.BNBRewardsFee();
        uint256 preLiq = token.liquidityFee();
        uint256 preMarketing = token.marketingFee();
        uint256 preBuyBack = token.buyBackAndBurnFee();
        uint256 preTotal = token.totalFees();
        
        console.log("Pre-attack BNBRewardsFee: ", preBNB);
        console.log("Pre-attack liquidityFee: ", preLiq);
        console.log("Pre-attack marketingFee: ", preMarketing);
        console.log("Pre-attack buyBackAndBurnFee: ", preBuyBack);
        console.log("Pre-attack totalFees: ", preTotal);
        
        console.log("\n--- Trigger Attack ---");
        // Perform attack: owner sets dangerously high fees
        vm.startPrank(OWNER);
        token.setBNBRewardsFee(12);    // 12%
        token.setLiquiditFee(12);      // 12%
        token.setMarketingFee(13);     // 13%
        token.setbuyBackAndBurnFee(13); // 13%
        vm.stopPrank();
        
        console.log("\n--- AFTER-Trigger Fee Settings ---");
        // Query post-attack fees state
        uint256 postBNB = token.BNBRewardsFee();
        uint256 postLiq = token.liquidityFee();
        uint256 postMarketing = token.marketingFee();
        uint256 postBuyBack = token.buyBackAndBurnFee();
        uint256 postTotal = token.totalFees();
        
        console.log("Post-attack BNBRewardsFee: ", postBNB);
        console.log("Post-attack liquidityFee: ", postLiq);
        console.log("Post-attack marketingFee: ", postMarketing);
        console.log("Post-attack buyBackAndBurnFee: ", postBuyBack);
        console.log("Post-attack totalFees: ", postTotal);
        
        // Calculate validation metrics
        bool feesChanged = (preBNB != postBNB) || (preLiq != postLiq) || 
                          (preMarketing != postMarketing) || (preBuyBack != postBuyBack);
        bool totalReachedDanger = (postTotal >= 50);
        bool vulnerabilityExists = feesChanged && totalReachedDanger;
        
        console.log("\n--- Validation Results ---");
        console.log("Fees changed from initial state? ", feesChanged ? "YES" : "NO");
        console.log("Total fees reached dangerous level (>=50%)? ", totalReachedDanger ? "YES" : "NO");

        // Final vulnerability verdict
        if(vulnerabilityExists) {
            console.log("Vulnerability Exists: owner can set unsafe fee levels (50% total)");
        } else if (!feesChanged) {
            console.log("Vulnerability not Exist: fee settings did not persist");
        } else {
            console.log("Vulnerability not Exist: fee cap safety mechanism is effective");
        }
    }
}