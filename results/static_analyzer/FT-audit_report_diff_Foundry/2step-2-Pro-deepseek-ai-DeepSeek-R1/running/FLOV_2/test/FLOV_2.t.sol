// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FLOV.sol";

contract FLOV_FeeOverflowTest is Test {
    FLOV token;
    address owner = address(0x1);
    address userA = address(0x2);
    address userB = address(0x3);
    
    // Constants for mock setup
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WETH_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address mockPair;
    
    function setUp() public {
        // Setup mock environment
        vm.startPrank(owner);
        
        // Mock router factory response
        address mockFactory = address(0x123);
        mockPair = address(0x456);
        
        // Mock router factory()
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        
        // Mock router WETH()
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH_ADDRESS)
        );
        
        // Mock factory createPair
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );
        
        // Deploy token contract
        token = new FLOV();
        
        // Setup initial conditions
        // Owner is already excluded in constructor - no need to exclude again
        token.setSwapTokensAtAmount(type(uint256).max); // Prevent swapping
        token.transfer(userA, 1000 * 10**18);
        token.setMarketingWallet(address(0x4)); // Set valid marketing wallet
        
        vm.stopPrank();
    }

    function test_FeeOverflow() public {
        // Set fees to dangerous values
        console.log("--- Setting dangerous fees ---");
        vm.startPrank(owner);
        token.setBUSDRewardsFee(50);  // 50%
        token.setLiquiditFee(50);     // 50%
        token.setMarketingFee(50);    // 50% (total 150%)
        vm.stopPrank();

        // Verify fee configuration
        console.log("Fee configuration complete (total 150%)");

        // Attempt transfer
        console.log("--- Trigger Transfer ---");
        console.log("Attempting transfer (should trigger overflow revert)");
        
        vm.prank(userA);
        vm.expectRevert("SafeMath: subtraction overflow");
        token.transfer(userB, 100 * 10**18);

        // Final verdict
        console.log("Vulnerability Exists: SafeMath subtraction overflow triggered during transfer");
    }
}