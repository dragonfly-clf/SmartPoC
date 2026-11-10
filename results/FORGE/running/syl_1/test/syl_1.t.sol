// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Sylvania.sol";

contract SylvaniaFeeManipulationTest is Test {
    Sylvania public token;
    address owner = address(1); // Use dedicated owner address
    
    // Constants for router and token addresses
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant FACTORY_ADDRESS = address(0xFa);
    address constant WETH_ADDRESS = address(0xEe);
    address constant PAIR_ADDRESS = address(0xDe);

    function setUp() public {
        // Mock router calls
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(FACTORY_ADDRESS)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH_ADDRESS)
        );
        
        // Mock factory call to create pair
        vm.mockCall(
            FACTORY_ADDRESS,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(PAIR_ADDRESS)
        );
        
        // Deploy token contract as owner
        vm.startPrank(owner);
        token = new Sylvania();
        vm.stopPrank();
    }
    
    function testBuyTaxesCanExceed25Percent() public {
        console.log("--- BEFORE-TRIGGER BUY TAX ---");
        uint256 initialBuyTax = token._totalTaxIfBuying();
        console.log("Initial Buy Tax Total: %s%", initialBuyTax);
        require(initialBuyTax <= 25, "Initial buy tax exceeds 25%");

        console.log("--- TRIGGER SET BUY TAXES ---");
        vm.startPrank(owner);
        token.setBuyTaxes(10, 10, 10); // 30% total
        vm.stopPrank();

        console.log("--- AFTER-TRIGGER BUY TAX ---");
        uint256 manipulatedBuyTax = token._totalTaxIfBuying();
        console.log("Manipulated Buy Tax Total: %s%", manipulatedBuyTax);
        
        bool taxExceeded = manipulatedBuyTax > 25;
        if (taxExceeded) {
            console.log("Verdict: Vulnerability Exists - Buy taxes set to %s%% exceeding 25%% cap", manipulatedBuyTax);
        } else {
            console.log("Verdict: Vulnerability not Exist - Buy taxes remain at %s%% within 25%% limit", manipulatedBuyTax);
        }
    }
    
    function testSellTaxesCanExceed25Percent() public {
        console.log("--- BEFORE-TRIGGER SELL TAX ---");
        uint256 initialSellTax = token._totalTaxIfSelling();
        console.log("Initial Sell Tax Total: %s%", initialSellTax);
        require(initialSellTax <= 25, "Initial sell tax exceeds 25%");

        console.log("--- TRIGGER SET SELL TAXES ---");
        vm.startPrank(owner);
        token.setSelTaxes(10, 10, 10); // 30% total
        vm.stopPrank();

        console.log("--- AFTER-TRIGGER SELL TAX ---");
        uint256 manipulatedSellTax = token._totalTaxIfSelling();
        console.log("Manipulated Sell Tax Total: %s%", manipulatedSellTax);
        
        bool taxExceeded = manipulatedSellTax > 25;
        if (taxExceeded) {
            console.log("Verdict: Vulnerability Exists - Sell taxes set to %s%% exceeding 25%% cap", manipulatedSellTax);
        } else {
            console.log("Verdict: Vulnerability not Exist - Sell taxes remain at %s%% within 25%% limit", manipulatedSellTax);
        }
    }
}