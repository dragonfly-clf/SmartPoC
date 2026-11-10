// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BingoGame.sol";

contract MockWETH {
    function deposit() public payable {}
    function withdraw(uint256) public {}
    receive() external payable {}
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234567890123456789012345678901234567890);
    }
}

contract MockRouter {
    address public immutable factory;
    address public immutable WETH;
    
    constructor(address _factory, address _weth) {
        factory = _factory;
        WETH = _weth;
    }
}

contract BingoGameFeeManipulationTest is Test {
    BingoGame token;
    address owner = address(0x1);
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Create mock contracts
        MockWETH mockWeth = new MockWETH();
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(mockWeth));
        
        // Copy mock router code to Pancake address
        vm.etch(PANCAKE_ROUTER, address(mockRouter).code);
        
        // Set storage slot 0 (factory address)
        bytes32 factorySlot = bytes32(uint256(0));
        bytes32 factoryValue = bytes32(uint256(uint160(address(mockFactory))));
        vm.store(PANCAKE_ROUTER, factorySlot, factoryValue);
        
        // Set storage slot 1 (WETH) - immutable so not truly mutable, but necessary for return values
        bytes32 wethSlot = bytes32(uint256(1));
        bytes32 wethValue = bytes32(uint256(uint160(address(mockWeth))));
        vm.store(PANCAKE_ROUTER, wethSlot, wethValue);
        
        // Deploy token
        vm.startPrank(owner);
        token = new BingoGame();
        vm.stopPrank();
    }

    function test_fee_manipulation() public {
        console.log("=== Testing Over 25% Fee Manipulation ===");
        
        // Verify owner can exceed 25% buy fee limit
        console.log("--- BEFORE-Trigger setBuyTaxes(15,11) ---");
        uint256 initialBuyTax = token._totalTaxIfBuying();
        console.log("Initial Buy Tax: %s%", initialBuyTax);
        
        console.log("--- Trigger setBuyTaxes(15,11) ---");
        vm.startPrank(owner);
        token.setBuyTaxes(15, 11);  // Total = 26%
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger setBuyTaxes ---");
        uint256 updatedBuyTax = token._totalTaxIfBuying();
        console.log("Updated Buy Tax: %s%", updatedBuyTax);
        require(updatedBuyTax == 26, "Buy tax not set to 26%");
        
        // Verify owner can exceed 25% sell fee limit
        console.log("--- BEFORE-Trigger setSelTaxes(20,6) ---");
        uint256 initialSellTax = token._totalTaxIfSelling();
        console.log("Initial Sell Tax: %s%", initialSellTax);
        
        console.log("--- Trigger setSelTaxes(20,6) ---");
        vm.startPrank(owner);
        token.setSelTaxes(20, 6);   // Total = 26%
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger setSelTaxes ---");
        uint256 updatedSellTax = token._totalTaxIfSelling();
        console.log("Updated Sell Tax: %s%", updatedSellTax);
        require(updatedSellTax == 26, "Sell tax not set to 26%");
        
        // Final verdict
        if(updatedBuyTax > 25 || updatedSellTax > 25) {
            console.log("Vulnerability Exists: Taxes successfully exceeded 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Tax limits enforced");
        }
    }

    function test_extreme_fee_manipulation() public {
        console.log("=== Testing Extreme Fee Manipulation (100%) ===");
        
        // Test buy tax
        console.log("--- BEFORE-Trigger setBuyTaxes(50,50) ---");
        uint256 initialBuyTax = token._totalTaxIfBuying();
        console.log("Initial Buy Tax: %s%", initialBuyTax);
        
        console.log("--- Trigger setBuyTaxes(50,50) ---");
        vm.startPrank(owner);
        token.setBuyTaxes(50, 50);  // Total = 100%
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger setBuyTaxes ---");
        uint256 updatedBuyTax = token._totalTaxIfBuying();
        console.log("Updated Buy Tax: %s%", updatedBuyTax);
        
        // Test sell tax
        console.log("--- BEFORE-Trigger setSelTaxes(99,1) ---");
        uint256 initialSellTax = token._totalTaxIfSelling();
        console.log("Initial Sell Tax: %s%", initialSellTax);
        
        console.log("--- Trigger setSelTaxes(99,1) ---");
        vm.startPrank(owner);
        token.setSelTaxes(99, 1);   // Total = 100%
        vm.stopPrank();
        
        console.log("--- AFTER-Trigger setSelTaxes ---");
        uint256 updatedSellTax = token._totalTaxIfSelling();
        console.log("Updated Sell Tax: %s%", updatedSellTax);
        
        // Final verdict
        if(updatedBuyTax == 100 && updatedSellTax == 100) {
            console.log("Vulnerability Exists: Taxes successfully set to 100%%");
        } else {
            console.log("Vulnerability not Exist: 100%% tax setting restricted");
        }
    }
}