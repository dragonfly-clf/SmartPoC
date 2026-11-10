// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

contract MockUniswapV2Router {
    address public factory;

    constructor(address _factory) {
        factory = _factory;
    }

    function WETH() external pure returns (address) {
        return address(0x456);
    }
}

contract CoinTokenTest is Test {
    CoinToken token;
    address tokenOwner = address(0x1);
    address feeAddress = address(0x2);
    address serviceAddress = address(0x3);
    MockUniswapV2Factory factory;
    MockUniswapV2Router router;

    function setUp() public {
        // Deploy mock Uniswap components
        factory = new MockUniswapV2Factory();
        router = new MockUniswapV2Router(address(factory));

        // Deploy CoinToken with essential parameters
        token = new CoinToken(
            "TestToken", 
            "TT", 
            18, 
            1000000, 
            1,   // initial taxFee
            1,   // initial lpFee
            1,   // initial devFee
            address(router),
            feeAddress,
            tokenOwner,
            serviceAddress
        );
    }

    function testSetExcessiveTaxFee() public {
        // Pre-trigger state
        console.log("--- BEFORE-Trigger Tax Fee ---");
        uint256 taxFeeBefore = token._taxFee();
        console.log("Current tax fee: %", taxFeeBefore);
        assertEq(taxFeeBefore, 1, "Initial tax fee should be 1%");

        console.log("--- Trigger: setTaxFeePercent(26) ---");
        vm.prank(tokenOwner);
        token.setTaxFeePercent(26);

        // Post-trigger state
        console.log("--- AFTER-Trigger Taxon Fee ---");
        uint256 taxFeeAfter = token._taxFee();
        console.log("Current tax fee: %", taxFeeAfter);
        
        // Differential validation
        if (taxFeeAfter == 26) {
            console.log("Vulnerability Exists: Excessive tax fee (26%) successfully set");
            console.log("Vulnerability Exists: Protocol allows tax fees above 25%");
        } else {
            console.log("Vulnerability not Exist: Tax fee remains within safe limits");
            console.log("Vulnerability not Exist: Protected tax fee threshold");
        }
    }
}