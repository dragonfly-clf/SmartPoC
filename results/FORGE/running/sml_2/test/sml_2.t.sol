// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SuperMoonLotto.sol";

contract MockRouter is IUniswapV2Router02 {
    function factory() external pure override returns (address) {
        return address(0x1234);
    }
    
    function WETH() external pure override returns (address) {
        return address(0x5678);
    }
    
    function addLiquidity(
        address, address, uint, uint, uint, uint, address, uint
    ) external pure override returns (uint, uint, uint) {
        return (0, 0, 0);
    }
    
    function addLiquidityETH(
        address, uint, uint, uint, address, uint
    ) external payable override returns (uint, uint, uint) {
        return (0, 0, 0);
    }
    
    function swapExactTokensForETH(
        uint, uint, address[] calldata, address, uint
    ) external pure override returns (uint[] memory amounts) {
        amounts = new uint[](2);
        return amounts;
    }
    
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address, uint, uint, uint, address, uint
    ) external pure override returns (uint) {
        return 0;
    }
    
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint, address[] calldata, address, uint
    ) external payable override {}
    
    function swapExactETHForTokens(
        uint, address[] calldata, address, uint
    ) external payable override returns (uint[] memory amounts) {
        amounts = new uint[](2);
        return amounts;
    }
    
    function swapTokensForExactETH(
        uint, uint, address[] calldata, address, uint
    ) external pure override returns (uint[] memory amounts) {
        amounts = new uint[](2);
        return amounts;
    }
    
    function swapETHForExactTokens(
        uint, address[] calldata, address, uint
    ) external payable override returns (uint[] memory amounts) {
        amounts = new uint[](2);
        return amounts;
    }
    
    function quote(uint, uint, uint) external pure override returns (uint) {
        return 0;
    }
    
    function getAmountIn(uint, uint, uint) external pure override returns (uint) {
        return 0;
    }
    
    function getAmountOut(uint, uint, uint) external pure override returns (uint) {
        return 0;
    }
    
    function getAmountsIn(uint, address[] calldata) external pure override returns (uint[] memory amounts) {
        amounts = new uint[](2);
        return amounts;
    }
    
    function getAmountsOut(uint, address[] calldata) external pure override returns (uint[] memory amounts) {
        amounts = new uint[](2);
        return amounts;
    }
    
    function removeLiquidity(
        address, address, uint, uint, uint, address, uint
    ) external pure override returns (uint, uint) {
        return (0, 0);
    }
    
    function removeLiquidityETH(
        address, uint, uint, uint, address, uint
    ) external pure override returns (uint, uint) {
        return (0, 0);
    }
    
    function removeLiquidityWithPermit(
        address, address, uint, uint, uint, address, uint, bool, uint8, bytes32, bytes32
    ) external pure override returns (uint, uint) {
        return (0, 0);
    }
    
    function removeLiquidityETHWithPermit(
        address, uint, uint, uint, address, uint, bool, uint8, bytes32, bytes32
    ) external pure override returns (uint, uint) {
        return (0, 0);
    }
    
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address, uint, uint, uint, address, uint, bool, uint8, bytes32, bytes32
    ) external pure override returns (uint) {
        return 0;
    }
    
    function swapExactTokensForTokens(
        uint, uint, address[] calldata, address, uint
    ) external pure override returns (uint[] memory amounts) {
        amounts = new uint[](2);
        return amounts;
    }
    
    function swapTokensForExactTokens(
        uint, uint, address[] calldata, address, uint
    ) external pure override returns (uint[] memory amounts) {
        amounts = new uint[](2);
        return amounts;
    }
    
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint, uint, address[] calldata, address, uint
    ) external pure override {}
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, uint, address[] calldata, address, uint
    ) external pure override {}
}

contract FeeLimitTest is Test {
    SuperMoonLotto token;
    MockRouter mockRouter;
    
    address constant MOCK_FACTORY = address(0x1234);
    
    function setUp() public {
        // Deploy mock router
        mockRouter = new MockRouter();
        
        // Mock factory creation
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSelector(IUniswapV2Factory.createPair.selector),
            abi.encode(address(0x1111))
        );
        
        // Deploy token
        token = new SuperMoonLotto(address(mockRouter));
    }

    function testFeesCanExceed25Percent() public {
        console.log("--- BEFORE-Trigger Fee Status ---");
        // Get initial fee percentages
        uint256 taxFeeBefore = token._taxFee();
        uint256 liquidityFeeBefore = token._liquidityFee();
        uint256 moonFeeBefore = token._moonFee();
        
        console.log("Initial Tax Fee: %d%%", taxFeeBefore);
        console.log("Initial Liquidity Fee: %d%%", liquidityFeeBefore);
        console.log("Initial Moon Fee: %d%%", moonFeeBefore);
        
        console.log("--- Trigger Attack ---");
        // Attempt to set fees beyond 25% limit (each 30%)
        token.setTaxFeePercent(30);
        token.setLiquidityFeePercent(30);
        token.setMoonFeePercent(30);
        
        console.log("--- AFTER-Trigger Fee Status ---");
        // Get updated fee percentages
        uint256 taxFeeAfter = token._taxFee();
        uint256 liquidityFeeAfter = token._liquidityFee();
        uint256 moonFeeAfter = token._moonFee();
        
        console.log("Updated Tax Fee: %d%%", taxFeeAfter);
        console.log("Updated Liquidity Fee: %d%%", liquidityFeeAfter);
        console.log("Updated Moon Fee: %d%%", moonFeeAfter);
        
        // Check if any fee exceeds 25%
        bool feesExceedLimit = taxFeeAfter > 25 || liquidityFeeAfter > 25 || moonFeeAfter > 25;
        console.log("Validation Result:");
        console.log("TaxF exceeds 25%%: %s", taxFeeAfter > 25 ? "YES" : "NO");
        console.log("LiqF exceeds 25%%: %s", liquidityFeeAfter > 25 ? "YES" : "NO");
        console.log("MoonF exceeds 25%%: %s", moonFeeAfter > 25 ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (feesExceedLimit) {
            console.log("Vulnerability Exists: Fees were successfully set above the 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Fees did not exceed 25%% after attack");
        }
    }
}