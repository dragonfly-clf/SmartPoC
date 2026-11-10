// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DOGE1.sol";

interface IUniswapV2Router {
    function WETH() external pure returns (address);
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
}

contract MaliciousRouter is IUniswapV2Router {
    bool public swapSuccess;
    bool public liquiditySuccess;
    uint256 public ethToSend;

    constructor(bool _swapSuccess, bool _liquiditySuccess, uint256 _ethToSend) {
        swapSuccess = _swapSuccess;
        liquiditySuccess = _liquiditySuccess;
        ethToSend = _ethToSend;
    }

    function WETH() external pure override returns (address) {
        return address(0xDead);
    }

    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint,
        uint,
        address[] calldata,
        address to,
        uint
    ) external override {
        if (!swapSuccess) revert("Swap failed");
        payable(to).transfer(ethToSend);
    }

    function addLiquidityETH(
        address,
        uint,
        uint,
        uint,
        address,
        uint
    ) external payable override returns (uint, uint, uint) {
        if (!liquiditySuccess) revert("Add liquidity failed");
        return (0, 0, 0);
    }
}

contract DOGE1Test is Test {
    DOGE1 token;
    MaliciousRouter router;
    address owner = makeAddr("owner");
    address marketing = makeAddr("marketing");

    function setUp() public {
        vm.startPrank(owner);
        token = new DOGE1();
        vm.stopPrank();
    }

    function test_swap_failure_reverts_properly() public {
        router = new MaliciousRouter(false, true, 0);
        deal(address(router), 1 ether);
        
        vm.expectRevert("Swap failed");
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            100,
            0,
            _getSwapPath(address(token)),
            address(token),
            block.timestamp
        );
    }

    function test_liquidity_failure_reverts_properly() public {
        router = new MaliciousRouter(true, false, 0);
        deal(address(router), 1 ether);
        deal(address(this), 1 ether);
        
        vm.expectRevert("Add liquidity failed");
        router.addLiquidityETH{value: 1 ether}(
            address(token),
            100,
            0,
            0,
            address(this),
            block.timestamp
        );
    }

    function test_swap_balances_handled_correctly() public {
        router = new MaliciousRouter(true, true, 1 ether);
        deal(address(router), 1 ether);
        
        console.log("--- BEFORE swap ---");
        uint256 initialEthBalance = address(token).balance;
        uint256 initialTokenBalance = token.balanceOf(address(token));
        console.log("Initial Token Contract ETH Balance:", initialEthBalance);
        console.log("Initial Token Contract Token Balance:", initialTokenBalance);
        
        console.log("--- Trigger swap ---");
        router.swapExactTokensForETHSupportingFeeOnTransferTokens(
            100,
            0,
            _getSwapPath(address(token)),
            address(token),
            block.timestamp
        );
        
        console.log("--- AFTER swap ---");
        uint256 finalEthBalance = address(token).balance;
        uint256 finalTokenBalance = token.balanceOf(address(token));
        console.log("Final Token Contract ETH Balance:", finalEthBalance);
        console.log("Final Token Contract Token Balance:", finalTokenBalance);
        
        uint256 ethDifference = finalEthBalance - initialEthBalance;
        int256 tokenDifference = int256(finalTokenBalance) - int256(initialTokenBalance);
        console.log("ETH Difference (Expected 1 ether):", ethDifference);
        console.log("Token Balance Change (Expected 0):", tokenDifference);
        
        bool ethCorrect = ethDifference == 1 ether;
        bool tokenCorrect = tokenDifference == 0;
        bool vulnerabilityExists = !(ethCorrect && tokenCorrect);
        
        console.log("--- Verification ---");
        console.log("ETH increased as expected:", ethCorrect ? "Yes" : "No");
        console.log("Token balance unchanged:", tokenCorrect ? "Yes" : "No");
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: ETH and/or token balance change unexpected");
        } else {
            console.log("Vulnerability not Exist: Balances changed consistently");
        }
        
        // Foundry assertions for test integrity
        assertEq(ethDifference, 1 ether, "ETH balance mismatch");
        assertEq(finalTokenBalance, initialTokenBalance, "Token balance changed");
    }

    function _getSwapPath(address tokenIn) private pure returns (address[] memory) {
        address[] memory path = new address[](2);
        path[0] = tokenIn;
        path[1] = address(0xDead);
        return path;
    }
}