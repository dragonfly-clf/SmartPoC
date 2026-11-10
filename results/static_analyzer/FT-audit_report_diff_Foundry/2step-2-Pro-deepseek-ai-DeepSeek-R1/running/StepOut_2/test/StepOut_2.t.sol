// SPDX-License-Identifier: MIT
pragma solidity 0.8.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {stdError} from "forge-std/StdError.sol";
import "../src/StepOut.sol";

contract MockRouter {
    function factory() external pure returns (address) {
        return 0x1111111111111111111111111111111111111111; // All lowercase address
    }

    function WETH() external pure returns (address) {
        return 0x2222222222222222222222222222222222222222; // 40 character address
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return 0x3333333333333333333333333333333333333333; // All lowercase address
    }
}

contract StepOutTest is Test {
    StepOut token;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E; // Real router address
    address constant FACTORY_ADDR = 0x1111111111111111111111111111111111111111; // Mock factory address
    address constant PAIR_ADDR = 0x3333333333333333333333333333333333333333;    // Mock pair address

    function setUp() public {
        // Create mock contracts
        MockRouter mockRouter = new MockRouter();
        MockFactory mockFactory = new MockFactory();
        
        // Assign mock code to required addresses
        vm.etch(ROUTER_ADDR, address(mockRouter).code);
        vm.etch(FACTORY_ADDR, address(mockFactory).code);
        
        vm.startPrank(owner);
        token = new StepOut();
        
        // Set excessive tax rates (100% each) to trigger underflow
        token.setTaxes(100, 100, 100);
        
        // Transfer initial tokens to test user
        uint256 aliceAmount = 100 * 10 ** token.decimals();
        token.transfer(alice, aliceAmount);
        vm.stopPrank();
    }

    function testTransferRevertsOnArithmeticUnderflow() public {
        uint256 transferAmount = 100 * 10 ** token.decimals();
        
        vm.startPrank(alice);
        
        // Attempt transfer should revert due to arithmetic underflow
        // Fee calculations: 100% base + 100% liquidity + 100% burn = 300%)
        vm.expectRevert(stdError.arithmeticError);
        token.transfer(bob, transferAmount);
        vm.stopPrank();
        
        // Final verdict - vulnerability exists because transfer reverts as expected
        console.log("--- Vulnerability Verdict ---");
        console.log("Vulnerability Exists: Transfer reverts due to arithmetic underflow caused by excessive tax settings");
    }
}