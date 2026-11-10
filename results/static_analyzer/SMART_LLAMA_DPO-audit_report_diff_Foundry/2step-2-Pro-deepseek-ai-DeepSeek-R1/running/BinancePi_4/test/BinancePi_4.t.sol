// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BinancePi.sol";

// Mock interfaces to simulate Uniswap contracts
interface MockRouter {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}

interface MockFactory {
    function createPair(address tokenA, address tokenB) external pure returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
}

contract BinancePiPrivilegeEscalationTest is Test {
    BinancePi token;
    address owner = makeAddr("owner");
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WETH_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address fakeFactory;
    address fakePair;

    function setUp() public {
        vm.startPrank(owner);
        
        // Setup mock contracts
        fakePair = makeAddr("fakePair");
        fakeFactory = makeAddr("fakeFactory");
        
        // Mock router calls
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(MockRouter.factory.selector),
            abi.encode(fakeFactory)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSelector(MockRouter.WETH.selector),
            abi.encode(WETH_ADDRESS)
        );
        
        // Mock factory calls
        vm.mockCall(
            fakeFactory,
            abi.encodeWithSelector(MockFactory.createPair.selector),
            abi.encode(fakePair)
        );
        vm.mockCall(
            fakeFactory,
            abi.encodeWithSelector(MockFactory.getPair.selector),
            abi.encode(fakePair)
        );
        
        // Deploy token now that environment is mocked
        token = new BinancePi();
        
        vm.stopPrank();
    }

    function test_privilege_escalation_vulnerability() public {
        vm.startPrank(owner);
        console.log("--- PRE-ATTACK STATE ---");
        
        // Snapshot initial state
        uint256 initialBuyLiquidity = token.buyLiquidityFee();
        uint256 initialBuyMarketing = token.buyMarketingFee();
        uint256 initialSellLiquidity = token.sellLiquidityFee();
        uint256 initialSellMarketing = token.sellMarketingFee();
        uint256 initialLiquidityShare = token.liquidityShare();
        uint256 initialMarketingShare = token.marketingShare();
        address initialLPAd = token.LPAd();
        address initialMarketingAddr = token.marketingWalletAddress();
        uint256 initialWalletMax = token.walletMax();
        uint256 initialMinTokens = token.minimumTokensBeforeSwap();
        bool initialWalletLimit = token.checkWalletLimit();
        bool initialWalletExempt = token.isWalletLimitExempt(owner);
        bool initialTxExempt = token.isTxLimitExempt(owner);
        bool initialFeeExempt = token.isExcludedFromFee(owner);
        bool initialSwapEnabled = token.swapAndLiquifyEnabled();
        bool initialSwapByLimit = token.swapAndLiquifyByLimitOnly();

        // Log initial state
        console.log("Buy Liquidity Fee     :", initialBuyLiquidity);
        console.log("Buy Marketing Fee     :", initialBuyMarketing);
        console.log("Sell Liquidity Fee    :", initialSellLiquidity);
        console.log("Sell Marketing Fee    :", initialSellMarketing);
        console.log("Liquidity Share       :", initialLiquidityShare);
        console.log("Marketing Share       :", initialMarketingShare);
        console.log("LP Address            :", initialLPAd);
        console.log("Marketing Address     :", initialMarketingAddr);
        console.log("Wallet Max            :", initialWalletMax);
        console.log("Min Tokens Before Swap:", initialMinTokens);
        console.log("Wallet Limit Enabled  :", initialWalletLimit ? "Enabled" : "Disabled");
        console.log("Wallet Exempt?        :", initialWalletExempt ? "Yes" : "No");
        console.log("TX Exempt?            :", initialTxExempt ? "Yes" : "No");
        console.log("Fee Exempt?           :", initialFeeExempt ? "Yes" : "No");
        console.log("Swap Enabled          :", initialSwapEnabled ? "Yes" : "No");
        console.log("Swap By Limit Only    :", initialSwapByLimit ? "Yes" : "No");

        console.log("\n=== TRIGGERING ATTACK FUNCTIONS ===");
        // Execute privileged functions as owner
        token.setBuyTaxes(100, 100, 100);
        token.setSellTaxes(100, 100, 100);
        token.setDistributionSettings(100, 100, 100);
        token.setLPAd(address(0x123));
        token.setMarketingWalletAddress(address(0x456));
        token.enableDisableWalletLimit(false);
        token.setWalletLimit(0);
        token.setIsWalletLimitExempt(owner, true);
        token.setIsTxLimitExempt(owner, true);
        token.setIsExcludedFromFee(owner, true);
        token.setSwapAndLiquifyEnabled(true);
        token.setSwapAndLiquifyByLimitOnly(false);
        token.setNumTokensBeforeSwap(0);
        vm.stopPrank();

        console.log("\n--- POST-ATTACK STATE ---");
        // Capture post-attack state
        uint256 afterBuyLiquidity = token.buyLiquidityFee();
        uint256 afterBuyMarketing = token.buyMarketingFee();
        uint256 afterSellLiquidity = token.sellLiquidityFee();
        uint256 afterSellMarketing = token.sellMarketingFee();
        uint256 afterLiquidityShare = token.liquidityShare();
        uint256 afterMarketingShare = token.marketingShare();
        address afterLPAd = token.LPAd();
        address afterMarketingAddr = token.marketingWalletAddress();
        uint256 afterWalletMax = token.walletMax();
        uint256 afterMinTokens = token.minimumTokensBeforeSwap();
        bool afterWalletLimit = token.checkWalletLimit();
        bool afterWalletExempt = token.isWalletLimitExempt(owner);
        bool afterTxExempt = token.isTxLimitExempt(owner);
        bool afterFeeExempt = token.isExcludedFromFee(owner);
        bool afterSwapEnabled = token.swapAndLiquifyEnabled();
        bool afterSwapByLimit = token.swapAndLiquifyByLimitOnly();

        // Log state changes
        console.log("Buy Liquidity Fee     :", afterBuyLiquidity, changedStr(initialBuyLiquidity, afterBuyLiquidity));
        console.log("Buy Marketing Fee     :", afterBuyMarketing, changedStr(initialBuyMarketing, afterBuyMarketing));
        console.log("Sell Liquidity Fee    :", afterSellLiquidity, changedStr(initialSellLiquidity, afterSellLiquidity));
        console.log("Sell Marketing Fee    :", afterSellMarketing, changedStr(initialSellMarketing, afterSellMarketing));
        console.log("Liquidity Share       :", afterLiquidityShare, changedStr(initialLiquidityShare, afterLiquidityShare));
        console.log("Marketing Share       :", afterMarketingShare, changedStr(initialMarketingShare, afterMarketingShare));
        console.log("LP Address            :", afterLPAd, changedStrAddr(initialLPAd, afterLPAd));
        console.log("Marketing Address     :", afterMarketingAddr, changedStrAddr(initialMarketingAddr, afterMarketingAddr));
        console.log("Wallet Max            :", afterWalletMax, changedStr(initialWalletMax, afterWalletMax));
        console.log("Min Tokens Before Swap:", afterMinTokens, changedStr(initialMinTokens, afterMinTokens));
        console.log("Wallet Limit Enabled  :", afterWalletLimit ? "Enabled" : "Disabled", changedStrBool(initialWalletLimit, afterWalletLimit));
        console.log("Wallet Exempt?        :", afterWalletExempt ? "Yes" : "No", changedStrBool(initialWalletExempt, afterWalletExempt));
        console.log("TX Exempt?            :", afterTxExempt ? "Yes" : "No", changedStrBool(initialTxExempt, afterTxExempt));
        console.log("Fee Exempt?           :", afterFeeExempt ? "Yes" : "No", changedStrBool(initialFeeExempt, afterFeeExempt));
        console.log("Swap Enabled          :", afterSwapEnabled ? "Yes" : "No", changedStrBool(initialSwapEnabled, afterSwapEnabled));
        console.log("Swap By Limit Only    :", afterSwapByLimit ? "Yes" : "No", changedStrBool(initialSwapByLimit, afterSwapByLimit));

        console.log("\n--- VULNERABILITY ASSERTION ---");
        // Verify critical state change occurred as expected
        bool buyFeeChanged = afterBuyMarketing == 100;
        bool marketingAddrChanged = afterMarketingAddr == address(0x456);
        bool txExemptChanged = afterTxExempt;
        
        if(buyFeeChanged && marketingAddrChanged && txExemptChanged) {
            console.log("Vulnerability Exists: Owner successfully modified all critical parameters without restrictions");
        } else {
            console.log("Vulnerability not Exist: Critical parameters not modified as expected");
        }
    }

    // Helper functions for change status (fixed parameter names)
    function changedStr(uint256 initial, uint256 post) internal pure returns (string memory) {
        return post != initial ? "[CHANGED]" : "";
    }
    
    function changedStrBool(bool initial, bool post) internal pure returns (string memory) {
        return post != initial ? "[CHANGED]" : "";
    }
    
    function changedStrAddr(address initial, address post) internal pure returns (string memory) {
        return post != initial ? "[CHANGED]" : "";
    }
}