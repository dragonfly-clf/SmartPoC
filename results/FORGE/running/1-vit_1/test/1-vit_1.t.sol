// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TokenTool.sol";

contract TokenToolFeeTest is Test {
    TokenTool token;
    address owner = address(0x1);
    address marketingAddress = address(0x2);
    address teamAddress = address(0x3);
    address service = address(0x4);
    uint256 private constant TAX_THRESHOLD = 2500; // 25% threshold in basis points
    
    function setUp() public {
        vm.deal(owner, 1 ether);
        vm.startPrank(owner);

        // Deploy mock Uniswap components
        MockUniswapV2Factory factory = new MockUniswapV2Factory();
        MockUniswapV2Router02 router = new MockUniswapV2Router02(address(factory));

        // Deploy TokenTool with necessary parameters
        token = new TokenTool{value: 0.1 ether}(
            "TestToken",
            "TST",
            18,
            1_000_000_000,
            address(router),
            owner,
            marketingAddress,
            teamAddress,
            service
        );
        vm.stopPrank();
    }

    function test_BuyFeesOverLimit() public {
        // BEFORE: Query initial tax state
        console.log("--- BEFORE-Trigger Buy Fees ---");
        uint256 initialBuyTax = token._totalTaxIfBuying();
        uint256 initialSellTax = token._totalTaxIfSelling();
        console.log("Initial buy tax: %s (basis points)", initialBuyTax);
        console.log("Initial sell tax: %s (basis points)", initialSellTax);

        console.log("--- Trigger Set Buy Fees (over limit) ---");
        // Set buy fees above threshold
        vm.startPrank(owner);
        token.setBuyTaxes(30, 30, 30);        // Each component >25%
        token.setBuyDestFee(100);              // Destruction fee = 100%
        vm.stopPrank();

        // AFTER: Query updated tax state
        console.log("--- AFTER-Trigger Buy Fees ---");
        uint256 updatedBuyTax = token._totalTaxIfBuying();
        uint256 updatedSellTax = token._totalTaxIfSelling();
        console.log("Updated buy tax: %s (basis points)", updatedBuyTax);
        console.log("Updated sell tax: %s (basis points)", updatedSellTax);

        // Verify vulnerability exists
        bool isVulnerable = updatedBuyTax > TAX_THRESHOLD;
        console.log("Buy tax exceeds threshold: %s", isVulnerable ? "YES" : "NO");
        console.log("Vulnerability Exists: %s", isVulnerable ? 
            "Buy tax exceeds 25% limit" : 
            "Buy tax within acceptable range");

        // Final verdict
        if (isVulnerable) {
            console.log("Vulnerability Exists: Attack successfully modified buy tax beyond limits");
        } else {
            console.log("Vulnerability not Exist: Fee constraints correctly enforced");
        }
    }

    function test_SellFeesOverLimit() public {
        // BEFORE: Query initial tax state
        console.log("--- BEFORE-Trigger Sell Fees ---");
        uint256 initialBuyTax = token._totalTaxIfBuying();
        uint256 initialSellTax = token._totalTaxIfSelling();
        console.log("Initial buy tax: %s (basis points)", initialBuyTax);
        console.log("Initial sell tax: %s (basis points)", initialSellTax);

        console.log("--- Trigger Set Sell Fees (over limit) ---");
        // Set sell fees above threshold
        vm.startPrank(owner);
        token.setSelTaxes(25, 25, 30);        // Components exceed 25% cumulative
        token.setSellDestFee(120);             // Destruction fee = 120%
        vm.stopPrank();

        // AFTER: Query updated tax state
        console.log("--- AFTER-Trigger Sell Fees ---");
        uint256 updatedBuyTax = token._totalTaxIfBuying();
        uint256 updatedSellTax = token._totalTaxIfSelling();
        console.log("Updated buy tax: %s (basis points)", updatedBuyTax);
        console.log("Updated sell tax: %s (basis points)", updatedSellTax);

        // Verify vulnerability exists
        bool isVulnerable = updatedSellTax > TAX_THRESHOLD;
        console.log("Sell tax exceeds threshold: %s", isVulnerable ? "YES" : "NO");
        console.log("Vulnerability Exists: %s", isVulnerable ? 
            "Sell tax exceeds 25% limit" : 
            "Sell tax within acceptable range");

        // Final verdict
        if (isVulnerable) {
            console.log("Vulnerability Exists: Attack successfully modified sell tax beyond limits");
        } else {
            console.log("Vulnerability not Exist: Fee constraints correctly enforced");
        }
    }
}

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockUniswapV2Router02 {
    address public immutable factory;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    constructor(address _factory) {
        factory = _factory;
    }
}