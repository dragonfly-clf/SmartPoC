// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CHITAVERSE.sol";

contract TestDivisionTruncation is Test {
    CHITAVERSE token;
    address owner = makeAddr("owner");
    address DEAD = 0x000000000000000000000000000000000000dEaD;
    address pairAddress;
    address factoryAddress;
    
    function setUp() public {
        // Setup mock addresses
        pairAddress = makeAddr("mockPair");
        factoryAddress = makeAddr("mockFactory");

        // Mock router.factory() call
        vm.mockCall(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            abi.encodeWithSignature("factory()"),
            abi.encode(factoryAddress)
        );
        
        // Mock factory.createPair() call
        vm.mockCall(
            factoryAddress,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(pairAddress)
        );

        // Deploy token contract
        vm.startPrank(owner);
        token = new CHITAVERSE();
        
        // Configure environment (disable fees and limits for owner)
        token.setIsFeeExempt(owner, true);
        token.setTxLimit(type(uint256).max);
        vm.stopPrank();
    }

    function test_DivisionTruncation() public {
        // Get token decimals and compute base unit
        uint256 decimals = token.decimals();
        uint256 unit = 10 ** decimals;

        vm.startPrank(owner);
        // Transfer almost all supply to DEAD (99.997%)
        uint256 totalSupply = token.totalSupply();
        token.transfer(DEAD, totalSupply - (3 * unit));
        
        // Transfer 1 unit to token pair
        token.transfer(pairAddress, 1 * unit);
        vm.stopPrank();

        console.log("--- Balance Setup for Truncation Test ---");
        console.log("Balance of Pair Address:", token.balanceOf(pairAddress));
        console.log("Balance of Dead Address:", token.balanceOf(DEAD));
        console.log("Remaining Supply (owner):", token.balanceOf(owner));
        console.log("Total Supply:", totalSupply);

        console.log("--- Trigger: Call getLiquidityBacking ---");
        uint256 backing = token.getLiquidityBacking(10000);
        console.log("Liquidity Backing Value: ", backing);

        // Check for truncation vulnerability
        if (backing == 6666) {
            console.log("Vulnerability Exists: Integer division truncation causes incorrect calculation (backing=6666, should be 6667)");
        } else {
            console.log("Vulnerability not Exist: The calculation returned a value without truncation? Backing:", backing);
        }

        assertEq(backing, 6666, "Division truncation failure");
    }
}