// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CoinToken.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234);
    }
}

contract MockRouter {
    address private factory_;
    address private weth_;

    constructor(address _factory, address _weth) {
        factory_ = _factory;
        weth_ = _weth;
    }

    function factory() external view returns (address) {
        return factory_;
    }

    function WETH() external view returns (address) {
        return weth_;
    }
}

contract TaxFeeManipulationTest is Test {
    CoinToken public token;
    address owner = makeAddr("owner");
    address service = makeAddr("service");
    address feeRecipient = makeAddr("feeRecipient");

    function setUp() public {
        // Create necessary mock contracts
        MockFactory factory = new MockFactory();
        MockRouter router = new MockRouter(address(factory), address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2)); // Using standard WETH address

        // Fund owner and deploy token
        vm.deal(owner, 10 ether);
        vm.startPrank(owner);

        token = new CoinToken{value: 1 ether}(
            "TestToken", 
            "TST", 
            18,                     // Decimals
            1_000_000,              // Supply (1 million)
            10,                     // Initial tax fee (10%)
            5,                      // Liquidity fee (5%)
            2,                      // Dev fee (2%)
            address(router),        // Router address
            feeRecipient,           // Dev fee recipient
            owner,                  // Token owner
            service                 // Service address
        );
        vm.stopPrank();
    }

    function testFeeManipulation() public {
        // Before any manipulation
        uint256 initialTaxFee = token._taxFee();
        console.log("--- BEFORE-Trigger (Initial State) ---");
        console.log("Initial tax fee: ", initialTaxFee);
        require(initialTaxFee == 10, "Initial tax fee should be 10%");

        // First critical action: set to 26%
        console.log("--- Trigger: setTaxFeePercent(26) ---");
        vm.prank(owner);
        token.setTaxFeePercent(26);

        console.log("--- AFTER-Trigger (Set 26%) ---");
        uint256 taxFeeAfter26 = token._taxFee();
        console.log("Tax fee after set: ", taxFeeAfter26);

        // Second critical action: set to 100%
        console.log("--- Trigger: setTaxFeePercent(100) ---");
        vm.prank(owner);
        token.setTaxFeePercent(100);

        console.log("--- AFTER-Trigger (Set 100%) ---");
        uint256 taxFeeAfter100 = token._taxFee();
        console.log("Tax fee after set: ", taxFeeAfter100);

        // Final verification and verdict
        console.log("--- Vulnerability Verification ---");
        bool exploitPossible = (taxFeeAfter26 == 26) && (taxFeeAfter100 == 100);
        
        if (exploitPossible) {
            console.log("Vulnerability Exists: Tax fee can be set beyond safe limits (26% and 100%)");
        } else {
            console.log("Vulnerability not Exist: Tax fee remains within expected parameters");
        }
    }

    function testNonOwnerCannotSetFees() public {
        address attacker = address(0x999);
        
        // Attempt to set fees as non-owner
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTaxFeePercent(20);
    }
}