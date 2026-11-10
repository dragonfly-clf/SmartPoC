// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SLAMDUNKINU.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0xface); // Factory address
    }
    
    function WETH() external pure returns (address) {
        return address(0xbbbb); // Mock WETH address
    }
}

contract MockFactory {
    function createPair(address tokenA, address tokenB) external returns (address) {
        return address(0xabcd); // Mock pair address
    }
}

contract SLAMDUNKINUFeeManipulationTest is Test {
    SLAMDUNKINU public token;
    address public owner = makeAddr("owner");
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Setup mock router at Pancake address
        MockRouter mockRouter = new MockRouter();
        vm.etch(PANCAKE_ROUTER, address(mockRouter).code);
        
        // Setup mock factory
        MockFactory mockFactory = new MockFactory();
        vm.etch(address(0xface), address(mockFactory).code);
        
        // Deploy token (test contract is initial owner)
        token = new SLAMDUNKINU();
        
        // Transfer ownership to test user
        token.transferOwnership(payable(owner));
        
        // Grant owner privileges to test user
        vm.prank(owner);
        token.authorize(owner);
    }

    function test_fee_manipulation() public {
        uint256 liquidityFee = 10;
        uint256 buybackFee = 5;
        uint256 reflectionFee = 5;
        uint256 marketingFee = 6; // Total = 26%
        uint256 feeDenominator = 100;

        // BEFORE trigger state snapshot
        console.log("--- BEFORE-Trigger getTotalFee ---");
        uint256 preTotalFee = token.getTotalFee(false);
        console.log("Initial total fee (%):", preTotalFee);

        // Trigger vulnerability exploitation
        console.log("--- Trigger setFees (26%) ---");
        vm.prank(owner);
        token.setFees(
            liquidityFee,
            buybackFee,
            reflectionFee,
            marketingFee,
            feeDenominator
        );

        // AFTER trigger state snapshot
        console.log("--- AFTER-Trigger getTotalFee ---");
        uint256 postTotalFee = token.getTotalFee(false);
        console.log("Updated total fee (%):", postTotalFee);
        bool feeChanged = postTotalFee != preTotalFee;

        // Differential verification - check fee change & 25% cap violation
        bool exceedsLimit = postTotalFee > 25;
        console.log("Fee change detected:", feeChanged);
        console.log("Exceeds 25%% limit:", exceedsLimit);
        
        // Final vulnerability verdict
        if (exceedsLimit) {
            console.log("Vulnerability Exists: Fee successfully set above 25%% limit");
        } else {
            console.log("Vulnerability not Exist: Fee remains within 25%% limit");
        }
    }
}