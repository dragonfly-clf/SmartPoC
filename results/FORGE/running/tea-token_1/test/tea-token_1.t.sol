// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TeaToken.sol";

contract TeaTokenFeeManipulationTest is Test {
    TeaToken token;
    address owner = address(0x1);
    uint256 maxAllowedFee = 25; // 25% fee limit
    address constant ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    
    // Helper addresses
    address mockFactory = address(0x3);
    address mockWETH = address(0x4);
    address mockPair = address(0x5);

    function _encodeArgs(address tokenA, address tokenB) internal pure returns (bytes memory) {
        return abi.encodeWithSignature("createPair(address,address)", tokenA, tokenB);
    }

    function setUp() public {
        vm.startPrank(owner);
        
        // Precompute token address before deployment
        uint256 nonce = vm.getNonce(owner);
        address tokenAddress = computeCreateAddress(owner, nonce);

        // Mock Uniswap router calls
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        
        // Mock createPair call with precomputed token address
        vm.mockCall(
            mockFactory,
            _encodeArgs(tokenAddress, mockWETH),
            abi.encode(mockPair)
        );

        // Deploy token after mocks are set
        token = new TeaToken();
        vm.stopPrank();
    }

    function testSetTaxFeeBeyondLimit() public {
        console.log("--- BEFORE-Trigger TaxFee ---");
        uint256 initialTaxFee = token._taxFee();
        console.log("Initial tax fee:", initialTaxFee, "%");
        
        console.log("--- Trigger SetTaxFeePercent ---");
        vm.prank(owner);
        token.setTaxFeePercent(maxAllowedFee + 1); // Attempt to set to 26%
        
        console.log("--- AFTER-Trigger TaxFee ---");
        uint256 newTaxFee = token._taxFee();
        console.log("New tax fee:", newTaxFee, "%");
        
        if (newTaxFee == maxAllowedFee + 1 && newTaxFee > maxAllowedFee) {
            console.log("Vulnerability Exists: Tax fee was set beyond max allowed limit");
        } else {
            console.log("Vulnerability not Exist: Tax fee respects max allowed limit");
        }
    }

    function testSetLiquidityFeeBeyondLimit() public {
        console.log("--- BEFORE-Trigger LiquidityFee ---");
        uint256 initialLiquidityFee = token._liquidityFee();
        console.log("Initial liquidity fee:", initialLiquidityFee, "%");
        
        console.log("--- Trigger SetLiquidityFeePercent ---");
        vm.prank(owner);
        token.setLiquidityFeePercent(maxAllowedFee + 1); // Attempt to set to 26%
        
        console.log("--- AFTER-Trigger LiquidityFee ---");
        uint256 newLiquidityFee = token._liquidityFee();
        console.log("New liquidity fee:", newLiquidityFee, "%");
        
        if (newLiquidityFee == maxAllowedFee + 1 && newLiquidityFee > maxAllowedFee) {
            console.log("Vulnerability Exists: Liquidity fee was set beyond max allowed limit");
        } else {
            console.log("Vulnerability not Exist: Liquidity fee respects max allowed limit");
        }
    }
}