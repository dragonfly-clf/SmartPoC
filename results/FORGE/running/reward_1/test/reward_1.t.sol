// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TokenReward.sol";

contract MockPinkAntiBot {
    function setTokenOwner(address) external {}
    function enableAntiBot(bool) external {}
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract MockFactory {
    address immutable pair;
    
    constructor(address _pair) {
        pair = _pair;
    }
    
    function createPair(address, address) external view returns (address) {
        return pair;
    }
}

contract MockPair {}

contract TokenRewardFeeManipulationTest is Test {
    TokenReward token;
    address constant OWNER = 0x8b4145a7a3c381E30de988F19D6958b4dA7aBD79;
    address constant PINK_ANTI_BOT = 0x8EFDb3b642eb2a20607ffe0A56CFefF6a95Df002;
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;
    
    MockPinkAntiBot pinkAntiBot;
    MockRouter router;
    MockFactory factory;
    MockPair pair;

    function setUp() public {
        // Create mock dependencies
        pinkAntiBot = new MockPinkAntiBot();
        pair = new MockPair();
        factory = new MockFactory(address(pair));
        router = new MockRouter(address(factory), WETH);
        
        // Set mock code at required addresses
        vm.etch(PINK_ANTI_BOT, address(pinkAntiBot).code);
        vm.etch(ROUTER, address(router).code);
        
        // Deploy token contract
        vm.startPrank(OWNER);
        token = new TokenReward();
        
        // Disable features that could interfere with test
        token.setEnableAntiBot(false);
        token.setAutoRebase(false);
        token.setAutoAddLiquidity(false);
        vm.stopPrank();
    }

    function test_owner_can_exceed_25_percent_fee_using_sellFeef() public {
        vm.startPrank(OWNER);
        
        console2.log("--- BEFORE-Trigger State ---");
        uint256 initialBaseFees = token.liquidityFee() + 
                                 token.treasuryFee() + 
                                 token.firePitFee() + 
                                 token.riskFreeValueFee();
        uint256 initialSellFeef = token.sellFeef();
        uint256 feeDenom = token.feeDenominator();
        console2.log("Initial total base fees: %s (%s%%)", 
            initialBaseFees, 
            initialBaseFees * 100 / feeDenom);
        console2.log("Initial sellFeef: %s (%s%%)", 
            initialSellFeef, 
            initialSellFeef * 100 / feeDenom);
            
        console2.log("--- Trigger: setFees() Call ---");
        // Attempt fee manipulation
        token.setFees(
            40,    // liquidityFee (4%)
            40,    // treasuryFee (4%)
            1000,  // feeDenominator
            40,    // firePitFee (4%)
            0,     // sellFeel
            0,     // sellFeet
            300,   // sellFeef (30%) - vulnerability exploited here
            30     // riskFreeValueFee (3%)
        );
        
        console2.log("--- AFTER-Trigger State ---");
        uint256 newBaseFees = token.liquidityFee() + 
                             token.treasuryFee() + 
                             token.firePitFee() + 
                             token.riskFreeValueFee();
        uint256 newSellFeef = token.sellFeef();
        console2.log("Updated total base fees: %s (%s%%)", 
            newBaseFees, 
            newBaseFees * 100 / feeDenom);
        console2.log("Updated sellFeef: %s (%s%%)", 
            newSellFeef, 
            newSellFeef * 100 / feeDenom);
        
        // Validate fee percentage violation
        bool baseFeesExceedLimit = (newBaseFees * 100 / feeDenom) >= 25;
        bool sellFeefExceedsLimit = (newSellFeef * 100 / feeDenom) > 25;
        
        console2.log("Base fees exceed 25%%: %s", baseFeesExceedLimit ? "YES" : "NO");
        console2.log("sellFeef exceeds 25%%: %s", sellFeefExceedsLimit ? "YES" : "NO");
        
        // Generate verdict
        if (!baseFeesExceedLimit && sellFeefExceedsLimit) {
            console2.log("Vulnerability Exists: Owner bypassed 25%% limit for sell fees");
        } else {
            console2.log("Vulnerability not Exist: Contract prevents setting fees beyond limits");
        }
        
        // Original assertions preserved
        assertEq(token.sellFeef(), 300, "Owner set sellFeef to 30% despite 25% limit");
        assertTrue(newBaseFees * 4 < feeDenom, "Base fees exceed 25%");
        
        vm.stopPrank();
    }
}