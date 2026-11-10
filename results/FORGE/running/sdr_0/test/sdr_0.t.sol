// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Binflow.sol";

contract BinflowBurnTest is Test {
    Binflow token;
    address constant MAINNET_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    
    address deployer;
    address user = address(0x123);
    address constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public {
        deployer = address(this);
        
        // Mock router dependencies
        vm.mockCall(
            MAINNET_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(0x1234567890))
        );
        
        vm.mockCall(
            MAINNET_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(WETH)
        );
        
        vm.mockCall(
            address(0x1234567890),
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(0xabcdef))
        );
        
        // Deploy token contract
        token = new Binflow();
        
        // Set up test user with initial tokens
        uint256 decimals = token.decimals();
        uint256 tokensToTransfer = 10000 * (10 ** decimals);
        token.transfer(user, tokensToTransfer);
    }

    // Helper to get actual token balance (accounting for reflections)
    function _getActualBalance(address account) internal view returns (uint256) {
        if (token.isExcludedFromReward(account)) {
            return token.balanceOf(account);
        } else {
            return token.tokenFromReflection(token.balanceOf(account));
        }
    }

    function test_OwnerCanBurnAnyTokens() public {
        // Get actual balance before burn
        uint256 balanceBefore = _getActualBalance(user);
        uint256 burnAmount = 1000 * (10 ** token.decimals());
        
        console.log("--- BEFORE-Trigger Burn ---");
        console.log("User balance: %s tokens", balanceBefore);
        console.log("Burn amount: %s tokens", burnAmount);
        
        // Perform the burn
        console.log("--- Trigger Burn ---");
        token.burn(user, burnAmount);
        
        // Check balance after burn
        console.log("--- AFTER-Trigger Burn ---");
        uint256 balanceAfter = _getActualBalance(user);
        console.log("User balance: %s tokens", balanceAfter);
        
        // Differential verification
        uint256 computedDifference = balanceBefore - balanceAfter;
        console.log("Calculated difference: %s tokens", computedDifference);
        console.log("Expected difference: %s tokens", burnAmount);
        
        // Final vulnerability verdict
        if (computedDifference == burnAmount) {
            console.log("Vulnerability Exists: Owner can burn any user's tokens without approval.");
        } else {
            console.log("Vulnerability not Exist: Burn operation did not execute as expected.");
        }
    }

    function test_NonOwnerCannotBurnTokens() public {
        uint256 burnAmount = 1000 * (10 ** token.decimals());
        
        // Attempt token burn from non-owner address
        vm.prank(address(0x456));
        vm.expectRevert();
        token.burn(user, burnAmount);
    }
}