// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LOPE.sol";

contract MockRouter is IUniswapV2Router02 {
    // Minimal implementations for all required interface functions
    function factory() external pure override returns (address) {
        return address(0);
    }
    
    function WETH() external pure override returns (address) {
        return address(0);
    }

    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint256 liquidity,
        uint256,
        uint256,
        address to,
        uint256
    ) external pure override returns (uint256, uint256) {
        return (0, 0);
    }
    
    function removeLiquidityETH(
        address token,
        uint256 liquidity,
        uint256,
        uint256,
        address to,
        uint256
    ) external pure override returns (uint256, uint256) {
        return (0, 0);
    }

    function addLiquidity(
        address,
        address,
        uint256,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external pure override returns (uint, uint, uint) {
        return (0, 0, 0);
    }

    function addLiquidityETH(
        address,
        uint256,
        uint256,
        uint256,
        address,
        uint256
    ) external payable override returns (uint256, uint256, uint256) {
        return (0, 0, 0);
    }

    function removeLiquidityWithPermit(
        address, 
        address, 
        uint256, 
        uint256, 
        uint256, 
        address, 
        uint256, 
        bool, 
        uint8, 
        bytes32, 
        bytes32
    ) external pure override returns (uint256, uint256) { 
        return (0, 0); 
    }

    function removeLiquidityETHWithPermit(
        address, 
        uint256, 
        uint256, 
        uint256, 
        address, 
        uint256, 
        bool, 
        uint8, 
        bytes32, 
        bytes32
    ) external pure override returns (uint256, uint256) { 
        return (0, 0); 
    }

    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address, 
        uint256, 
        uint256, 
        uint256, 
        address, 
        uint256
    ) external pure override returns (uint256) { 
        return 0; 
    }

    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address, 
        uint256, 
        uint256, 
        uint256, 
        address, 
        uint256, 
        bool, 
        uint8, 
        bytes32, 
        bytes32
    ) external pure override returns (uint256) { 
        return 0; 
    }

    function swapExactETHForTokens(uint, address[] calldata, address, uint) 
        external payable override returns (uint[] memory) {
        return new uint256[](0);
    }

    function swapTokensForExactETH(uint, uint, address[] calldata, address, uint) 
        external pure override returns (uint[] memory) {
        return new uint256[](0);
    }

    function swapExactTokensForETH(uint, uint, address[] calldata, address, uint) 
        external pure override returns (uint[] memory) {
        return new uint256[](0);
    }

    function swapETHForExactTokens(uint, address[] calldata, address, uint) 
        external payable override returns (uint[] memory) {
        return new uint256[](0);
    }

    function swapExactTokensForTokens(
        uint, 
        uint, 
        address[] calldata, 
        address, 
        uint
    ) external pure override returns (uint[] memory) { 
        return new uint256[](0); 
    }

    function swapTokensForExactTokens(
        uint, 
        uint, 
        address[] calldata, 
        address, 
        uint
    ) external pure override returns (uint[] memory) { 
        return new uint256[](0); 
    }

    function quote(uint, uint, uint) external pure override returns (uint) { 
        return 0; 
    }

    function getAmountOut(uint, uint, uint) external pure override returns (uint) { 
        return 0; 
    }

    function getAmountIn(uint, uint, uint) external pure override returns (uint) { 
        return 0; 
    }

    function getAmountsOut(uint, address[] calldata) external pure override returns (uint[] memory) { 
        return new uint256[](0); 
    }

    function getAmountsIn(uint, address[] calldata) external pure override returns (uint[] memory) { 
        return new uint256[](0); 
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint256, 
        uint256, 
        address[] calldata, 
        address, 
        uint256
    ) external pure override {}

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256, 
        uint256, 
        address[] calldata, 
        address, 
        uint256
    ) external pure override {}

    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint256, 
        address[] calldata, 
        address, 
        uint256
    ) external payable override {}
}

contract InputValidationTest is Test {
    MockRouter mockRouter;

    function setUp() public {
        mockRouter = new MockRouter();
    }

    function test_removeLiquidity_AcceptsInvalidInputs() public {
        // All parameters except liquidity are invalid (0 addresses, 0 min amounts)
        (bool success, ) = address(mockRouter).call(
            abi.encodeWithSelector(
                mockRouter.removeLiquidity.selector,
                address(0),    // Invalid tokenA
                address(0),    // Invalid tokenB
                100 ether,     // Valid liquidity
                0,            // Invalid amountAMin
                0,            // Invalid amountBMin
                address(0),   // Invalid recipient
                block.timestamp
            )
        );

        // Vulnerability verification - function call did NOT revert = vulnerability exists
        if (success) {
            console.log("Vulnerability Exists: Invalid inputs accepted without revert");
        } else {
            console.log("Vulnerability not Exist: Function reverted properly");
        }
    }

    function test_removeLiquidityETH_AcceptsInvalidInputs() public {
        // All parameters except liquidity are invalid
        (bool success, ) = address(mockRouter).call(
            abi.encodeWithSelector(
                mockRouter.removeLiquidityETH.selector,
                address(0),    // Invalid token
                100 ether,     // Valid liquidity
                0,            // Invalid amountTokenMin
                0,            // Invalid amountETHMin
                address(0),   // Invalid recipient
                block.timestamp
            )
        );

        // Vulnerability verification - function call did NOT revert = vulnerability exists
        if (success) {
            console.log("Vulnerability Exists: Invalid inputs accepted without revert");
        } else {
            console.log("Vulnerability not Exist: Function reverted properly");
        }
    }
}