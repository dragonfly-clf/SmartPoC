// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MajorDOGE.sol";

contract PrivilegeEscalationTest is Test {
    MajorDOGE token;
    address owner = address(0x1);
    address newMarketingWallet = address(0x2);
    address newTeamWallet = address(0x3);

    function setUp() public {
        // Fork BSC mainnet to ensure router address exists
        uint256 forkId = vm.createFork("https://bsc-dataseed.binance.org/");
        vm.selectFork(forkId);
        
        // Deploy contract as owner
        vm.prank(owner);
        token = new MajorDOGE();
    }

    function testFeeManipulationAndWalletControl() public {
        console.log("--- BEFORE-Trigger State ---");
        // Capture all initial fee parameters
        uint256 initBuyLiquidity = token._buyLiquidityFee();
        uint256 initBuyMarketing = token._buyMarketingFee();
        uint256 initBuyTeam = token._buyTeamFee();
        uint256 initSellLiquidity = token._sellLiquidityFee();
        uint256 initSellMarketing = token._sellMarketingFee();
        uint256 initSellTeam = token._sellTeamFee();
        address initMarketingWallet = token.marketingWalletAddress();
        address initTeamWallet = token.teamWalletAddress();

        // Log initial state
        console.log("Initial Buy Liquidity Fee:", initBuyLiquidity);
        console.log("Initial Buy Marketing Fee:", initBuyMarketing);
        console.log("Initial Buy Team Fee:", initBuyTeam);
        console.log("Initial Sell Liquidity Fee:", initSellLiquidity);
        console.log("Initial Sell Marketing Fee:", initSellMarketing);
        console.log("Initial Sell Team Fee:", initSellTeam);
        console.log("Initial Marketing Wallet:", initMarketingWallet);
        console.log("Initial Team Wallet:", initTeamWallet);

        console.log("\n--- Trigger Privilege Escalation Actions ---");
        vm.startPrank(owner);

        // Set buy taxes to 100% (10000 basis points)
        token.setBuyTaxes(10000, 0, 0);

        // Set sell taxes to 100% (10000 basis points)
        token.setSellTaxes(10000, 0, 0);

        // Change fee destination wallets
        token.setMarketingWalletAddress(newMarketingWallet);
        token.setTeamWalletAddress(newTeamWallet);

        // Set fees to extreme values (50000 = 500% each, total 1500%)
        token.setBuyTaxes(50000, 50000, 50000);
        token.setSellTaxes(50000, 50000, 50000);

        vm.stopPrank();

        console.log("\n--- AFTER-Trigger State ---");
        // Capture final state after all attacks
        uint256 finalBuyLiquidity = token._buyLiquidityFee();
        uint256 finalBuyMarketing = token._buyMarketingFee();
        uint256 finalBuyTeam = token._buyTeamFee();
        uint256 finalSellLiquidity = token._sellLiquidityFee();
        uint256 finalSellMarketing = token._sellMarketingFee();
        uint256 finalSellTeam = token._sellTeamFee();
        address finalMarketingWallet = token.marketingWalletAddress();
        address finalTeamWallet = token.teamWalletAddress();

        // Log final state
        console.log("Final Buy Liquidity Fee:", finalBuyLiquidity);
        console.log("Final Buy Marketing Fee:", finalBuyMarketing);
        console.log("Final Buy Team Fee:", finalBuyTeam);
        console.log("Final Sell Liquidity Fee:", finalSellLiquidity);
        console.log("Final Sell Marketing Fee:", finalSellMarketing);
        console.log("Final Sell Team Fee:", finalSellTeam);
        console.log("Final Marketing Wallet:", finalMarketingWallet);
        console.log("Final Team Wallet:", finalTeamWallet);

        console.log("\n--- Verification ---");
        // Verify vulnerability conditions
        bool feesOverflow = finalBuyLiquidity == 50000 && 
                            finalBuyMarketing == 50000 && 
                            finalBuyTeam == 50000 &&
                            finalSellLiquidity == 50000 &&
                            finalSellMarketing == 50000 &&
                            finalSellTeam == 50000;
        
        bool walletsChanged = (finalMarketingWallet != initMarketingWallet) && 
                              (finalTeamWallet != initTeamWallet);

        bool vulnerabilityExists = feesOverflow && walletsChanged;

        if (vulnerabilityExists) {
            console.log("VULNERABILITY EXIST: Owner can arbitrarily configure fees >100% and redirect wallets");
        } else {
            if (!feesOverflow) console.log("* Fees not exceeded in final state");
            if (!walletsChanged) console.log("* Wallet addresses unchanged");
            console.log("VULNERABILITY NOT EXIST: Validation safeguards exist");
        }
    }
}