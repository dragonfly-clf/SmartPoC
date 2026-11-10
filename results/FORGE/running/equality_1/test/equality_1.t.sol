// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Equality.sol";

contract EqualityTaxTest is Test {
    Equality token;
    address owner = address(0x1);

    // Mock addresses for Uniswap components
    address constant UNISWAP_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY = address(0xFAC70C);
    address constant MOCK_WETH = address(0xCAFE);
    address constant MOCK_PAIR = address(0xDEAD);

    function setUp() public {
        // Mock Uniswap router responses
        vm.mockCall(
            UNISWAP_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        vm.mockCall(
            UNISWAP_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        
        // Mock Uniswap factory responses
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(MOCK_PAIR)
        );

        // Deploy token contract with mocked dependencies
        vm.startPrank(owner);
        token = new Equality();
        vm.stopPrank();
    }

    function testBuyTaxExceeds25PercentLimit() public {
        console.log("--- BEFORE Trigger: Get current tax values ---");
        uint256 liqBefore = token._buyLiquidityFee();
        uint256 marketBefore = token._buyMarketingFee();
        uint256 teamBefore = token._buyTeamFee();
        uint256 totalBefore = liqBefore + marketBefore + teamBefore;
        
        console.log("Before - Liquidity Fee:", liqBefore);
        console.log("Before - Marketing Fee:", marketBefore);
        console.log("Before - Team Fee:", teamBefore);
        console.log("Before - Total Buy Tax (%):", totalBefore);
        console.log("------------------------------------------");
        
        console.log("--- TRIGGER: Set buy taxes to 33% each ---");
        vm.startPrank(owner);
        token.setBuyTaxes(33, 33, 33);
        vm.stopPrank();
        console.log("------------------------------------------");
        
        console.log("--- AFTER Trigger: Verify tax values changed ---");
        uint256 liqAfter = token._buyLiquidityFee();
        uint256 marketAfter = token._buyMarketingFee();
        uint256 teamAfter = token._buyTeamFee();
        uint256 totalAfter = liqAfter + marketAfter + teamAfter;
        
        console.log("After - Liquidity Fee:", liqAfter);
        console.log("After - Marketing Fee:", marketAfter);
        console.log("After - Team Fee:", teamAfter);
        console.log("After - Total Buy Tax (%):", totalAfter);
        console.log("------------------------------------------");
        
        // Verify state change and vulnerability existence
        bool feesChanged = (liqAfter != liqBefore) || 
                          (marketAfter != marketBefore) || 
                          (teamAfter != teamBefore);
        bool exceeds25Percent = (totalAfter > 25);
        
        console.log("State change:", feesChanged ? "YES" : "NO");
        console.log("Exceeds 25%:", exceeds25Percent ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (feesChanged && exceeds25Percent) {
            console.log("Vulnerability Exists: Successfully set buy tax beyond 25%% limit (Set to %s%%)", totalAfter);
        } else if (!feesChanged) {
            console.log("Vulnerability not Exist: Tax values did not change after operation");
        } else {
            console.log("Vulnerability not Exist: Total tax remains below 25%% limit");
        }
    }
}