// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/VegasCrypto.sol";

contract VegasCryptoPrivilegeTest is Test {
    VegasCrypto token;
    address owner = address(0x123);
    address attacker = address(0x456);
    address newLiquidityAddress = address(0x789);
    
    function setUp() public {
        vm.prank(owner);
        token = new VegasCrypto();
    }

    // Verify only owner can change post-presale fees
    function test_ownerCanAdjustPostPresaleFees() public {
        console.log("--- BEFORE-Trigger Function Call: afterPreSale by Owner ---");
        // No pre-state to snapshot since access control verification

        console.log("--- Trigger Function Call: afterPreSale by Owner ---");
        vm.prank(owner);
        token.afterPreSale(); // Should update fees without reverting

        console.log("--- AFTER-Trigger Function Success ---");
        console.log("Vulnerability not Exist: Owner successfully called afterPreSale (correct access control)");
    }

    // Verify attacker cannot change post-presale fees
    function test_attackerCannotAdjustFees() public {
        console.log("--- BEFORE-Trigger Function Call: afterPreSale by Attacker ---");
        // No pre-state to snapshot since access control verification
        
        console.log("--- Trigger Function Call: afterPreSale by Attacker ---");
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.afterPreSale();

        console.log("--- AFTER-Trigger Expected Revert Occurred ---");
        console.log("Vulnerability not Exist: Attacker was blocked from calling afterPreSale (access control enforced)");
    }

    // Verify only owner can change liquidity address
    function test_ownerCanChangeLiquidityAddress() public {
        console.log("--- BEFORE-Trigger Function Call: setLiquidityAddress by Owner ---");
        // No pre-state to snapshot since access control verification
        
        console.log("--- Trigger 1st Function Call: setLiquidityAddress by Owner ---");
        vm.startPrank(owner);
        token.setLiquidityAddress(newLiquidityAddress);
        
        console.log("--- Trigger 2nd Function Call: setLiquidityAddress by Owner ---");
        token.setLiquidityAddress(address(0xABC)); // Demonstrate multiple changes
        vm.stopPrank();

        console.log("--- AFTER-Trigger Function Success ---");
        console.log("Vulnerability not Exist: Owner successfully changed liquidity address (correct access control)");
    }

    // Verify attacker cannot change liquidity address
    function test_attackerCannotChangeLiquidityAddress() public {
        console.log("--- BEFORE-Trigger Function Call: setLiquidityAddress by Attacker ---");
        // No pre-state to snapshot since access control verification
        
        console.log("--- Trigger Function Call: setLiquidityAddress by Attacker ---");
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.setLiquidityAddress(newLiquidityAddress);

        console.log("--- AFTER-Trigger Expected Revert Occurred ---");
        console.log("Vulnerability not Exist: Attacker was blocked from changing liquidity address (access control enforced)");
    }
}