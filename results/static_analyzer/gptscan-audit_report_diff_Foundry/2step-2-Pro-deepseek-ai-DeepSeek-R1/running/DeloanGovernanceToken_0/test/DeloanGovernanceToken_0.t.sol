// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DeloanGovernanceToken.sol";

contract MockWETH {
    function deposit() external payable {}
    function withdraw(uint256) external {}
    function transfer(address, uint256) external pure returns (bool) {return true;}
}

contract MockUniswapV2Factory {
    function createPair(address, address) external returns (address) {
        return address(this);
    }
}

contract MockUniswapV2Pair {
    event Swap(uint amount0Out, uint amount1Out);
}

contract MockUniswapV2Router02 {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _WETH) {
        factory = _factory;
        WETH = _WETH;
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint, /* amountIn */
        uint, /* amountOutMin */
        address[] calldata, /* path */
        address to,
        uint /* deadline */
    ) external payable {
        // Simulate extremely bad slippage: return only 0.00001 eth per token
        payable(to).transfer(0.00001 ether);
    }
    
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint, uint, uint) {
        return (amountTokenDesired, msg.value, 0);
    }
}

contract NoSlippageTest is Test {
    DeloanGovernanceToken token;
    address constant OWNER = 0x23Fa43d0A5Ea9917A871F7542D2ca10877338f4B;
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    MockWETH public weth;
    MockUniswapV2Factory public factory;
    MockUniswapV2Router02 public router;
    
    function setUp() public {
        // Deploy mock contracts
        weth = new MockWETH();
        factory = new MockUniswapV2Factory();
        router = new MockUniswapV2Router02(address(factory), address(weth));
        
        // Replace existing PancakeRouter with mock
        vm.etch(PANCAKE_ROUTER, address(router).code);
        vm.deal(PANCAKE_ROUTER, 1000 ether);
        
        // Deploy token contract
        vm.startPrank(OWNER);
        token = new DeloanGovernanceToken();
        token.setSwapAndLiquifyEnabled(true);
        
        // Setup testing environment
        token.setLiquidityFeePercent(100); // 100% tax to accumulate tokens quickly
        token.setTaxFeePercent(0);
        token.setDevelopmentFeePercent(0);
        
        // Accumulate tokens in contract to trigger swapAndLiquify
        token.includeInFee(OWNER);
        token.transfer(address(0x123), token.balanceOf(OWNER) / 10);
        token.setLiquidityFeePercent(0); // Disable fees after accumulation
        
        vm.stopPrank();
    }

    function testNoSlippageProtection() public {
        vm.startPrank(OWNER);
        
        // BEFORE state: log token contract ETH balance
        console.log("--- BEFORE-Trigger: token contract ETH balance ---");
        uint256 baseETHBalance = address(token).balance;
        console.log("Before Trigger ETH balance: %s wei", baseETHBalance);

        console.log("--- Trigger: Transfer operation ---");
        // EXECUTE: Trigger swapAndLiquify via transfer
        token.transfer(address(0x456), 1 ether);

        // AFTER state: measure changes
        console.log("--- AFTER-Trigger: token contract ETH balance ---");
        uint256 finalETHBalance = address(token).balance;
        console.log("After Trigger ETH balance: %s wei", finalETHBalance);
        
        // Calculate difference
        uint256 netETHChange = finalETHBalance - baseETHBalance;
        console.log("Net ETH Change: %s wei", netETHChange);
        
        console.log("--- VERDICT: Vulnerability check ---");
        if (netETHChange < 0.001 ether) {
            console.log("Vulnerability Exists: Bad slippage allowed without protection");
        } else {
            console.log("Vulnerability not Exist: Normal slippage protection functioning");
        }
        
        vm.stopPrank();
    }
}