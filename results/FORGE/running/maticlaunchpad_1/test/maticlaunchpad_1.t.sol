// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MaticLaunchpad.sol";

// Minimal mock implementations for router and factory
contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }
    
    function WETH() external pure returns (address) {
        return address(0x2222222222222222222222222222222222222222);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x3333333333333333333333333333333333333333);
    }
}

contract FeeManipulationTest is Test {
    MaticLaunchpad token;
    address owner = address(0x1);
    
    function setUp() public {
        // Deploy mock router to fixed PancakeSwap router address
        address routerAddress = 0x05fF2B0DB69458A0750badebc4f9e13aDd608C7F;
        vm.etch(routerAddress, type(MockRouter).runtimeCode);
        
        // Deploy mock factory to fixed address
        address factoryAddress = 0x1111111111111111111111111111111111111111;
        vm.etch(factoryAddress, type(MockFactory).runtimeCode);
        
        // Deploy token contract
        vm.prank(owner);
        token = new MaticLaunchpad();
    }
    
    function test_fee_exceeds_max_limit() public {
        uint256 excessiveTaxFee = 26;
        uint256 excessiveLiquidityFee = 99;
        
        console.log("--- BEFORE-Trigger Fee Values ---");
        uint256 initialTaxFee = token._taxFee();
        uint256 initialLiquidityFee = token._liquidityFee();
        console.log("Initial tax fee: ", initialTaxFee);
        console.log("Initial liquidity fee: ", initialLiquidityFee);
        
        console.log("--- Trigger setTaxFeePercent and setLiquidityFeePercent ---");
        vm.prank(owner);
        token.setTaxFeePercent(excessiveTaxFee);
        
        vm.prank(owner);
        token.setLiquidityFeePercent(excessiveLiquidityFee);
        
        console.log("--- AFTER-Trigger Fee Values ---");
        uint256 updatedTaxFee = token._taxFee();
        uint256 updatedLiquidityFee = token._liquidityFee();
        console.log("Updated tax fee: ", updatedTaxFee);
        console.log("Updated liquidity fee: ", updatedLiquidityFee);
        
        // Vulnerability verification: Check if fees were set to excessive values
        bool taxFeeManipulated = updatedTaxFee == excessiveTaxFee;
        bool liquidityFeeManipulated = updatedLiquidityFee == excessiveLiquidityFee;
        bool vulnerabilityExists = taxFeeManipulated && liquidityFeeManipulated;
        
        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Both fees exceeded maximum allowed limits");
        } else {
            console.log("Vulnerability not Exist: Fee values not set to excessive amounts");
        }
    }
}