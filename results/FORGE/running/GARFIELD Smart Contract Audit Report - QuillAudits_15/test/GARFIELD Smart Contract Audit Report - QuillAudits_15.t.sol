// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GARFIELD.sol";

contract MockWETH {
    function deposit() external payable {}
    function withdraw(uint) external {}
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(new MockPair());
    }
}

contract MockPair {
    function sync() external {}
}

contract MockRouter {
    MockFactory public factory;
    address public immutable WETH;

    constructor() public {
        factory = new MockFactory();
        WETH = address(new MockWETH());
    }
    
    receive() external payable {}
}

contract GarfieldFeeRangeTest is Test {
    GARFIELD token;
    MockRouter router;
    
    address owner = address(0x1);
    address user = address(0x1001);

    function setUp() public {
        vm.prank(owner);
        router = new MockRouter();
        
        vm.prank(owner);
        token = new GARFIELD(payable(address(router)));
    }

    function test_owner_can_set_unlimited_fees() public {
        vm.startPrank(owner);
        
        console.log("--- Trigger SetTaxFeePercent(10000) ---");
        token.setTaxFeePercent(10000);
        
        console.log("--- Trigger SetLiquidityFeePercent(10000) ---");
        token.setLiquidityFeePercent(10000);
        
        console.log("--- Trigger SetMaxTxPercent(10001) ---");
        token.setMaxTxPercent(10001);
        
        vm.stopPrank();
        
        // Vulnerability verdict: function calls accepted invalid parameters without reverting
        console.log("Vulnerability Exists: Owner can set fees beyond contract design limits");
    }
    
    function test_non_owner_cannot_modify_fees() public {
        vm.startPrank(user);
        
        // TaxFeePercent
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTaxFeePercent(1);
        
        // LiquidityFeePercent
        vm.expectRevert("Ownable: caller is not the owner");
        token.setLiquidityFeePercent(1);
        
        // MaxTxPercent
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMaxTxPercent(1);
        
        vm.stopPrank();
    }
}