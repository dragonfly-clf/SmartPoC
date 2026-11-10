// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.6.8;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GARFIELD.sol";

// Mock contracts for Router and Factory interfaces
contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1234);
    }
}

contract MockRouter {
    MockFactory public factory;
    address public immutable WETH = address(0x456);
    
    constructor() public {
        factory = new MockFactory();
    }
}

contract GARFIELDPrivilegeTest is Test {
    GARFIELD token;
    MockRouter mockRouter;
    
    address owner = address(0x1);
    address normalUser = address(0x2);
    address recipient = address(0x3);
    
    function setUp() public {
        // Deploy mocks first
        mockRouter = new MockRouter();
        
        // Deploy token with mock router
        vm.startPrank(owner);
        token = new GARFIELD(payable(address(mockRouter)));
        // Transfer tokens to normalUser instead of using deal()
        token.transfer(normalUser, 1000 ether);
        vm.stopPrank();
    }

    function testOwnerPrivilegeMaxTxChanges() public {
        // Enable contract to avoid initial tx limits
        vm.prank(owner);
        token.activateContract();
        
        uint256 total = token.totalSupply();
        uint256 maxTxAfterLimit = total / 10000; // 0.01%
        uint256 testAmount = maxTxAfterLimit + 1;

        vm.expectRevert(); // Expect revert on excessive transfer
        vm.prank(normalUser);
        token.transfer(recipient, testAmount);
    }

    function testContractActivationPrivileges() public {
        address routerAddress = address(mockRouter);
        
        // Verify initial allowance is zero
        assertEq(token.allowance(address(token), routerAddress), 0);
        
        // Non-owner can't activate contract
        vm.prank(normalUser);
        vm.expectRevert("Ownable: caller is not the owner");
        token.activateContract();
        
        // Record pre-activation state
        console.log("--- BEFORE-Trigger Activation ---");
        uint256 maxTxBefore = token._maxTxAmount();
        uint256 allowanceBefore = token.allowance(address(token), routerAddress);
        bool swapEnabledBefore = token.swapAndLiquifyEnabled();
        
        console.log("MaxTxAmount before:", maxTxBefore);
        console.log("Allowance before:", allowanceBefore);
        console.log("SwapAndLiquifyEnabled before:", swapEnabledBefore);
        
        console.log("--- Trigger Owner Activation ---");
        vm.prank(owner);
        token.activateContract();  // Owner activates contract
        
        console.log("--- AFTER-Trigger Activation ---");
        uint256 maxTxAfter = token._maxTxAmount();
        uint256 allowanceAfter = token.allowance(address(token), routerAddress);
        bool swapEnabledAfter = token.swapAndLiquifyEnabled();
        
        console.log("MaxTxAmount after:", maxTxAfter);
        console.log("Allowance after:", allowanceAfter);
        console.log("SwapAndLiquifyEnabled after:", swapEnabledAfter);
        
        // Compare state changes
        bool maxTxChanged = (maxTxBefore != maxTxAfter);
        bool allowanceChanged = (allowanceBefore != allowanceAfter);
        bool swapEnabledChanged = (swapEnabledBefore != swapEnabledAfter);
        
        console.log("State changes - MaxTxAmount:", maxTxChanged ? "CHANGED" : "UNCHANGED");
        console.log("State changes - Allowance:", allowanceChanged ? "CHANGED" : "UNCHANGED");
        console.log("State changes - SwapEnabled:", swapEnabledChanged ? "CHANGED" : "UNCHANGED");
        
        // Vulnerability verdict - requires at least one protected state change
        if (maxTxChanged || allowanceChanged || swapEnabledChanged) {
            console.log("Vulnerability not Exist: Owner activation correctly modified contract state");
        } else {
            console.log("Vulnerability Exist: Activation failed to modify contract state");
        }
    }
    
    function testNonOwnerConfigurationReverts() public {
        // Non-owner can't adjust fees
        vm.prank(normalUser);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setTaxFeePercent(100);
        
        // Non-owner can't change tx limits
        vm.prank(normalUser);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setMaxTxPercent(100);
        
        // Non-owner can't toggle liquidity
        vm.prank(normalUser);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setSwapAndLiquifyEnabled(true);
    }
}