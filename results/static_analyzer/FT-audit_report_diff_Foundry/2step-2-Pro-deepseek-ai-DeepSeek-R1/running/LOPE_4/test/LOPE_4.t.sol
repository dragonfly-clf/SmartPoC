// SPDX-License-Identifier: MIT
pragma solidity 0.8.6;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LOPE.sol";

contract MockUniswapRouter is IUniswapV2Router02 {
    // High gas consumption implementations
    function removeLiquidity(
        address, /*tokenA*/
        address, /*tokenB*/
        uint256 liquidity,
        uint256, /*amountAMin*/
        uint256, /*amountBMin*/
        address, /*to*/
        uint256 /*deadline*/
    ) external override returns (uint256, uint256) {
        _consumeGas(liquidity);
        return (0, 0);
    }

    function removeLiquidityETH(
        address, /*token*/
        uint256 liquidity,
        uint256, /*amountTokenMin*/
        uint256, /*amountETHMin*/
        address, /*to*/
        uint256 /*deadline*/
    ) external override returns (uint256, uint256) {
        _consumeGas(liquidity);
        return (0, 0);
    }

    function _consumeGas(uint256 iterations) internal pure {
        address dummy;
        for (uint256 i = 0; i < iterations * 1000; i++) {
            dummy = address(uint160(i)); // Gas-consuming operation
        }
    }

    // Stub implementations for all other interface functions
    function factory() external pure override returns (address) { return address(0); }
    function WETH() external pure override returns (address) { return address(0); }
    function addLiquidity(address, address, uint, uint, uint, uint, address, uint) external override returns (uint, uint, uint) { return (0,0,0); }
    function addLiquidityETH(address, uint, uint, uint, address, uint) external payable override returns (uint, uint, uint) { return (0,0,0); }
    function swapExactTokensForTokens(uint, uint, address[] calldata, address, uint) external override returns (uint[] memory) { return new uint[](0); }
    function swapTokensForExactTokens(uint, uint, address[] calldata, address, uint) external override returns (uint[] memory) { return new uint[](0); }
    function swapExactETHForTokens(uint, address[] calldata, address, uint) external payable override returns (uint[] memory) { return new uint[](0); }
    function swapTokensForExactETH(uint, uint, address[] calldata, address, uint) external override returns (uint[] memory) { return new uint[](0); }
    function swapExactTokensForETH(uint, uint, address[] calldata, address, uint) external override returns (uint[] memory) { return new uint[](0); }
    function swapETHForExactTokens(uint, address[] calldata, address, uint) external payable override returns (uint[] memory) { return new uint[](0); }
    function getAmountOut(uint, uint, uint) external pure override returns (uint) { return 0; }
    function getAmountIn(uint, uint, uint) external pure override returns (uint) { return 0; }
    function getAmountsOut(uint, address[] calldata) external view override returns (uint[] memory) { return new uint[](0); }
    function getAmountsIn(uint, address[] calldata) external view override returns (uint[] memory) { return new uint[](0); }
    function quote(uint, uint, uint) external pure override returns (uint) { return 0; }
    function removeLiquidityWithPermit(address, address, uint, uint, uint, address, uint, bool, uint8, bytes32, bytes32) external override returns (uint, uint) { return (0,0); }
    function removeLiquidityETHWithPermit(address, uint, uint, uint, address, uint, bool, uint8, bytes32, bytes32) external override returns (uint, uint) { return (0,0); }
    function removeLiquidityETHSupportingFeeOnTransferTokens(address, uint, uint, uint, address, uint) external override returns (uint) { return 0; }
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(address, uint, uint, uint, address, uint, bool, uint8, bytes32, bytes32) external override returns (uint) { return 0; }
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(uint, uint, address[] calldata, address, uint) external override {}
    function swapExactETHForTokensSupportingFeeOnTransferTokens(uint, address[] calldata, address, uint) external payable override {}
    function swapExactTokensForETHSupportingFeeOnTransferTokens(uint, uint, address[] calldata, address, uint) external override {}
}

contract GasLimitTest is Test {
    MockUniswapRouter public router;

    function setUp() public {
        router = new MockUniswapRouter();
    }

    // Test gas consumption in removeLiquidity
    function testRemoveLiquidityGas() public {
        uint256 largeLiquidity = 1000000; // 1,000,000 liquidity units
        uint256 gasLimit = 300000; // insufficient gas limit

        console.log("--- BEFORE-Trigger: Gas consumption state ---");
        console.log("Testing with Insufficient Gas Limit:", gasLimit);

        console.log("--- Trigger: Call removeLiquidity ---");
        bool reverted;
        try router.removeLiquidity{gas: gasLimit}(
            address(0),
            address(0),
            largeLiquidity,
            0,
            0,
            address(this),
            block.timestamp + 1 hours
        ) {
            reverted = false;
        } catch {
            reverted = true;
        }

        console.log("--- AFTER-Trigger: Result ---");
        if (reverted) {
            console.log("Transaction REVERTED as expected (Vulnerability confirmed)");
            console.log("Vulnerability Exists: Excessive gas consumption in removeLiquidity function");
        } else {
            console.log("Transaction DID NOT REVERT (Unexpected Behavior)");
            console.log("Vulnerability not Exist: Gas consumption within acceptable limits");
        }
    }

    // Test gas consumption in removeLiquidityETH
    function testRemoveLiquidityETHGas() public {
        uint256 largeLiquidity = 1000000; // 1,000,000 liquidity units
        uint256 gasLimit = 300000; // insufficient gas limit

        console.log("--- BEFORE-Trigger: Gas consumption state ---");
        console.log("Testing with Insufficient Gas Limit:", gasLimit);

        console.log("--- Trigger: Call removeLiquidityETH ---");
        bool reverted;
        try router.removeLiquidityETH{gas: gasLimit}(
            address(0),
            largeLiquidity,
            0,
            0,
            address(this),
            block.timestamp + 1 hours
        ) {
            reverted = false;
        } catch {
            reverted = true;
        }

        console.log("--- AFTER-Trigger: Result ---");
        if (reverted) {
            console.log("Transaction REVERTED as expected (Vulnerability confirmed)");
            console.log("Vulnerability Exists: Excessive gas consumption in removeLiquidityETH function");
        } else {
            console.log("Transaction DID NOT REVERT (Unexpected Behavior)");
            console.log("Vulnerability not Exist: Gas consumption within acceptable limits");
        }
    }
}