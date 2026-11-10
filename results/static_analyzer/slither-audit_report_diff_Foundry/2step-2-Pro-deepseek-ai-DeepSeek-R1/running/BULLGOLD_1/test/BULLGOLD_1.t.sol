// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BULLGOLD.sol";

contract BULLGOLDTest is Test {
    BULLGOLD token;
    address constant DEPLOYER = address(0x1234);

    function setUp() public {
        // Prepare mock environment for token deployment
        address hardcodedRouter = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address mockFactory = address(0x1111);
        address mockWETH = address(0x2222);
        address mockPair = address(0x3333);

        // Mock PancakeRouter factory call
        vm.mockCall(
            hardcodedRouter,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        // Mock PancakeRouter WETH call
        vm.mockCall(
            hardcodedRouter,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );

        // Mock factory createPair call
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy token contract
        vm.startPrank(DEPLOYER);
        token = new BULLGOLD();
        vm.stopPrank();
    }

    /// @notice Tests correct reflection round-trip for total supply
    function testTotalSupplyReflectionConsistency() public {
        uint256 totalSupply = token.totalSupply();
        
        console.log("--- BEFORE-Trigger (initial amount) ---");
        console.log("Input token amount: %s", totalSupply);

        console.log("--- Trigger Reflection Conversion ---");
        uint256 rAmount = token.reflectionFromToken(totalSupply, false);
        uint256 tokensConverted = token.tokenFromReflection(rAmount);
        
        console.log("--- AFTER-Trigger (converted amount) ---");
        console.log("Converted token amount: %s", tokensConverted);

        if (totalSupply == tokensConverted) {
            console.log("Vulnerability not Exist: reflection conversion is consistent");
        } else {
            console.log("Vulnerability Exists: reflection conversion inconsistency");
        }
    }

    /// @notice Tests correct reflection round-trip for partial supply (1000 tokens)
    function testFixedAmountReflectionConsistency() public {
        // Get token decimals to calculate base amount (1000 * 10^decimals)
        uint8 decimals = token.decimals();
        uint256 testAmount = 1000 * (10 ** uint256(decimals));
        
        console.log("--- BEFORE-Trigger (initial amount) ---");
        console.log("Input token amount: %s", testAmount);

        console.log("--- Trigger Reflection Conversion ---");
        uint256 rAmount = token.reflectionFromToken(testAmount, false);
        uint256 tokensConverted = token.tokenFromReflection(rAmount);
        
        console.log("--- AFTER-Trigger (converted amount) ---");
        console.log("Converted token amount: %s", tokensConverted);

        if (testAmount == tokensConverted) {
            console.log("Vulnerability not Exist: reflection conversion is consistent");
        } else {
            console.log("Vulnerability Exists: reflection conversion inconsistency");
        }
    }

    /// @notice Tests correct reflection round-trip for 10% of total supply
    function testPartialSupplyReflectionConsistency() public {
        uint256 totalSupply = token.totalSupply();
        uint256 partialAmount = totalSupply / 10; // 10% of total supply
        
        console.log("--- BEFORE-Trigger (initial amount) ---");
        console.log("Input token amount: %s", partialAmount);

        console.log("--- Trigger Reflection Conversion ---");
        uint256 rPartial = token.reflectionFromToken(partialAmount, false);
        uint256 tokensConverted = token.tokenFromReflection(rPartial);
        
        console.log("--- AFTER-Trigger (converted amount) ---");
        console.log("Converted token amount: %s", tokensConverted);

        if (partialAmount == tokensConverted) {
            console.log("Vulnerability not Exist: reflection conversion is consistent");
        } else {
            console.log("Vulnerability Exists: reflection conversion inconsistency");
        }
    }
}