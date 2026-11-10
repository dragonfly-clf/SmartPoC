// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SpaceCat.sol";

contract MockWETH {
    function deposit() external payable {}
    function withdraw(uint) external {}
    function balanceOf(address) external pure returns (uint) { return 100 ether; }
    function transfer(address, uint) external pure returns (bool) { return true; }
    function transferFrom(address, address, uint) external pure returns (bool) { return true; }
    function approve(address, uint) external pure returns (bool) { return true; }
}

contract MockFactory {
    mapping(address => mapping(address => address)) public getPair;
    
    function createPair(address tokenA, address tokenB) external returns (address pair) {
        pair = address(uint160(uint(keccak256(abi.encode(tokenA, tokenB)))));
        getPair[tokenA][tokenB] = pair;
        getPair[tokenB][tokenA] = pair;
    }
}

contract MockRouter {
    address public factory;
    address public WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
    
    function addLiquidityETH(
        address token,
        uint,
        uint,
        uint,
        address,
        uint
    ) external virtual payable returns (uint, uint, uint) {
        IERC20(token).transferFrom(msg.sender, address(this), 0);
        return (0,0,0);
    }
}

contract SpaceCatFeeTest is Test {
    SpaceCat token;
    address owner = makeAddr("owner");
    address constant REAL_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    function setUp() public {
        // Deploy mock contracts with full functionality
        MockWETH weth = new MockWETH();
        MockFactory factory = new MockFactory();
        MockRouter router = new MockRouter(address(factory), address(weth));
        
        // Patch router at real address
        vm.etch(REAL_ROUTER, address(router).code);
        vm.store(REAL_ROUTER, bytes32(uint(0)), bytes32(uint256(uint160(address(factory)))));
        vm.store(REAL_ROUTER, bytes32(uint(1)), bytes32(uint256(uint160(address(weth)))));
        
        // Deploy token with environment configured
        vm.startPrank(owner);
        token = new SpaceCat();
        vm.stopPrank();
    }

    function testFeeManipulation() public {
        console.log("--- BEFORE-Trigger Tax States ---");
        uint256 initialBuyTax = token._totalTaxIfBuying();
        uint256 initialSellTax = token._totalTaxIfSelling();
        console.log("Initial Total Buy Tax: %", initialBuyTax);
        console.log("Initial Total Sell Tax: %", initialSellTax);

        // Set excessive taxes (10% each for 30% total)
        uint256 excessiveTax = 10;
        
        console.log("--- Trigger Change Fees ---");
        // Owner sets fees to excessive levels
        vm.prank(owner);
        token.setBuyTaxes(excessiveTax, excessiveTax, excessiveTax);
        
        vm.prank(owner);
        token.setSelTaxes(excessiveTax, excessiveTax, excessiveTax);

        console.log("--- AFTER-Trigger Tax States ---");
        uint256 finalBuyTax = token._totalTaxIfBuying();
        uint256 finalSellTax = token._totalTaxIfSelling();
        console.log("Final Total Buy Tax: %", finalBuyTax);
        console.log("Final Total Sell Tax: %", finalSellTax);
        
        // Verify tax state changes
        bool buyTaxChanged = finalBuyTax == 30;
        bool sellTaxChanged = finalSellTax == 30;
        console.log("Buy tax changed to 30: %s", buyTaxChanged ? "YES" : "NO");
        console.log("Sell tax changed to 30: %s", sellTaxChanged ? "YES" : "NO");
        
        // Final vulnerability verification
        if (buyTaxChanged && sellTaxChanged) {
            console.log("Vulnerability Exists: Taxes successfully manipulated to excessive 30%");
        } else {
            console.log("Vulnerability not Exist: Tax manipulation prevented (final buy tax: %s, sell tax: %s)", finalBuyTax, finalSellTax);
        }
    }
}