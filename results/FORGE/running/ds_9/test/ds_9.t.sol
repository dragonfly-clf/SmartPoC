// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DoctorShiba.sol";

contract DoctorShibaTest is Test {
    DoctorShiba token;
    address owner = address(0x1);
    address holder = address(0x2);
    address attacker = address(0x3);

    function setUp() public {
        vm.startPrank(owner);
        token = new DoctorShiba();
        // Leave 1000 ether with owner, transfer only 500 to holder
        token.transfer(holder, 500 ether);
        vm.stopPrank();
    }

    function test_owner_can_mint_at_will() public {
        console.log("--- BEFORE-Trigger: Mint ---");
        uint256 totalSupplyBefore = token.totalSupply();
        uint256 attackerBalanceBefore = token.balanceOf(attacker);
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        
        console.log("Initial total supply:", totalSupplyBefore);
        console.log("Attacker balance before mint:", attackerBalanceBefore);
        console.log("Owner balance before mint:", ownerBalanceBefore);

        console.log("--- Trigger: Minting 1000 ether to attacker ---");
        vm.prank(owner);
        token.mint(attacker, 1000 ether);
        
        console.log("--- AFTER-Trigger: Mint ---");
        uint256 totalSupplyAfter = token.totalSupply();
        uint256 attackerBalanceAfter = token.balanceOf(attacker);
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        
        console.log("Updated total supply:", totalSupplyAfter);
        console.log("Attacker balance after mint:", attackerBalanceAfter);
        console.log("Owner balance after mint:", ownerBalanceAfter);
        
        // State change validation
        bool supplyIncreased = totalSupplyAfter == totalSupplyBefore + 1000 ether;
        bool attackerReceived = attackerBalanceAfter == attackerBalanceBefore + 1000 ether;
        bool ownerBalancePreserved = ownerBalanceAfter == ownerBalanceBefore;
        
        // Vulnerability verdict
        if (supplyIncreased && attackerReceived && ownerBalancePreserved) {
            console.log("Vulnerability Exists: Owner can arbitrarily mint new tokens");
        } else {
            console.log("Vulnerability not Exist: Mint operation failed to alter state as expected");
        }

        // Updated assertions with consistent variable names
        assertEq(token.totalSupply(), totalSupplyBefore + 1000 ether, "Total supply not updated");
        assertEq(token.balanceOf(attacker), attackerBalanceBefore + 1000 ether, "Minted tokens not received");
        assertEq(
            token.balanceOf(owner), 
            ownerBalanceBefore, 
            "Owner balance changed unexpectedly"
        );
    }

    function test_owner_can_pause_transfers() public {
        console.log("--- BEFORE-Trigger: Pause State ---");
        bool isPausedBefore = token.paused();
        console.log("Contract paused status before:", isPausedBefore);
        assertFalse(isPausedBefore, "Contract should not be paused initially");

        console.log("--- Trigger: Owner pausing transfers ---");
        vm.prank(owner);
        token.pause();

        console.log("--- AFTER-Trigger: Pause State ---");
        bool isPausedAfter = token.paused();
        console.log("Contract paused status after:", isPausedAfter);
        
        // Vulnerability verdict
        if (!isPausedBefore && isPausedAfter) {
            console.log("Vulnerability Exists: Owner can arbitrarily pause transfers");
        } else {
            console.log("Vulnerability not Exist: Pause operation failed to alter contract state");
        }
        
        // Verify transfer reverts when paused
        vm.prank(holder);
        vm.expectRevert(); 
        token.transfer(attacker, 100 ether);
    }

    function test_owner_prevent_user_from_selling() public {
        address investor = address(0x4);
        
        // Transfer from owner to investor (setup)
        vm.prank(owner);
        token.transfer(investor, 500 ether);
        
        console.log("--- BEFORE-Trigger: Pause State ---");
        bool isPausedBefore = token.paused();
        console.log("Contract paused status before:", isPausedBefore);
        assertFalse(isPausedBefore, "Contract should not be paused initially");

        console.log("--- Trigger: Owner pausing contract ---");
        vm.prank(owner);
        token.pause();

        console.log("--- AFTER-Trigger: Pause State ---");
        bool isPausedAfter = token.paused();
        console.log("Contract paused status after:", isPausedAfter);
        
        // Vulnerability verdict
        if (!isPausedBefore && isPausedAfter) {
            console.log("Vulnerability Exists: Owner can arbitrarily prevent selling via pause");
        } else {
            console.log("Vulnerability not Exist: Pause operation failed to prevent selling");
        }
        
        // Verify transfer reverts when paused
        vm.prank(investor);
        vm.expectRevert(); 
        token.transfer(attacker, 500 ether);
    }

    function test_non_owner_cannot_mint() public {
        vm.prank(attacker);
        vm.expectRevert("Ownable: caller is not the owner");
        token.mint(attacker, 1000 ether);
    }

    function test_renounce_ownership_fixes_all_issues() public {
        // Owner renounces ownership
        vm.prank(owner);
        token.renounceOwnership();
        
        // Verify renouncing worked
        assertEq(token.owner(), address(0), "Ownership not renounced");

        // Test if minting fails after renounce
        vm.prank(owner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.mint(attacker, 1000 ether);
        
        // Test if pausing fails after renounce
        vm.prank(owner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.pause();
    }
}