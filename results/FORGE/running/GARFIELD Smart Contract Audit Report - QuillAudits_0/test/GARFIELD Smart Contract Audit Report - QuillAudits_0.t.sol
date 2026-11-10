// SPDX-License-Identifier: MIT
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GARFIELD.sol";

// Mock Pancake Factory with minimal implementation
contract MockPancakeFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x123);
    }
}

// Simplified Mock Router using built-in getters
contract MockPancakeRouter {
    MockPancakeFactory public factory;
    address public immutable WETH = address(0x456);
    
    constructor() public {
        factory = new MockPancakeFactory();
    }
}

contract GarfieldFeeTest is Test {
    GARFIELD token;
    address owner;
    MockPancakeRouter mockRouter;
    
    function setUp() public {
        owner = address(this);
        mockRouter = new MockPancakeRouter();
        token = new GARFIELD(payable(address(mockRouter)));
    }

    function testFeeManipulation() public {
        emit log("--- BEFORE-Trigger Fee State ---");
        // Capture initial fee states
        uint256 initialLiquidityFee = token._liquidityFee();
        uint256 initialTaxFee = token._taxFee();
        emit log_named_uint("Initial Liquidity Fee:", initialLiquidityFee);
        emit log_named_uint("Initial Tax Fee:", initialTaxFee);

        emit log("--- Trigger Fee Manipulation ---");
        // Attempt to set fees to 100%
        token.setLiquidityFeePercent(100);
        token.setTaxFeePercent(100);

        emit log("--- AFTER-Trigger Fee State ---");
        // Capture post-attack fee states
        uint256 newLiquidityFee = token._liquidityFee();
        uint256 newTaxFee = token._taxFee();
        emit log_named_uint("New Liquidity Fee:", newLiquidityFee);
        emit log_named_uint("New Tax Fee:", newTaxFee);

        bool feesChanged = (newLiquidityFee == 100) && (newTaxFee == 100);
        
        // Final vulnerability verification
        if (feesChanged) {
            emit log("Vulnerability Exists: Fees were increased to excessive levels (100%)");
        } else {
            emit log("Vulnerability not Exist: Fee limits are properly enforced");
        }
    }
}