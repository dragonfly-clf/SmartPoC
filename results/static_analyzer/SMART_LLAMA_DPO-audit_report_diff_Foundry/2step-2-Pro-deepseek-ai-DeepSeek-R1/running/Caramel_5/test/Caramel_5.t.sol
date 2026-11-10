// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Caramel.sol";

contract AtomicityTest is Test {
    Caramel public caramel;
    address public owner = address(0x1);
    address public alice = address(0x2);
    address public bob = address(0x3);
    
    uint256 public constant INITIAL_AMOUNT = 1000e18;
    uint256 public constant TRANSFER_AMOUNT = 100e18;
    uint256 public constant BURN_PERCENT = 2;
    uint256 public constant BURN_AMOUNT = TRANSFER_AMOUNT * BURN_PERCENT / 100;
    uint256 public constant RECIPIENT_AMOUNT = TRANSFER_AMOUNT - BURN_AMOUNT;
    uint256 public constant INITIAL_TOTAL_SUPPLY = 50000e18;

    function setUp() public {
        vm.startPrank(owner);
        caramel = new Caramel();
        caramel.mint(alice, INITIAL_AMOUNT);
        vm.stopPrank();
        
        assertEq(caramel.balanceOf(bob), 0, "Bob should start with zero balance");
    }

    function testTransferStateChanges() public {
        console.log("--- BEFORE-Transfer STATE ---");
        uint256 aliceBalanceBefore = caramel.balanceOf(alice);
        uint256 bobBalanceBefore = caramel.balanceOf(bob);
        uint256 totalSupplyBefore = caramel.totalSupply();
        console.log("Alice balance before:", aliceBalanceBefore);
        console.log("Bob balance before:", bobBalanceBefore);
        console.log("Total supply before:", totalSupplyBefore);

        console.log("--- TRIGGER Transfer ---");
        vm.prank(alice);
        caramel.transfer(bob, TRANSFER_AMOUNT);
        console.log("Transfer executed:", TRANSFER_AMOUNT, "tokens from Alice to Bob");

        console.log("--- AFTER-Transfer STATE ---");
        uint256 aliceBalanceAfter = caramel.balanceOf(alice);
        uint256 bobBalanceAfter = caramel.balanceOf(bob);
        uint256 totalSupplyAfter = caramel.totalSupply(); 
        console.log("Alice balance after:", aliceBalanceAfter);
        console.log("Bob balance after:", bobBalanceAfter);
        console.log("Total supply after:", totalSupplyAfter);
        
        console.log("--- STATE CHANGES ---");
        uint256 aliceDelta = aliceBalanceBefore - aliceBalanceAfter;
        uint256 bobDelta = bobBalanceAfter - bobBalanceBefore;
        uint256 supplyDelta = totalSupplyBefore - totalSupplyAfter;
        console.log("State Change: Alice balance decrease - Actual:", aliceDelta, "Expected:", TRANSFER_AMOUNT);
        console.log("State Change: Bob balance increase - Actual:", bobDelta, "Expected:", RECIPIENT_AMOUNT);
        console.log("State Change: Supply decrease - Actual:", supplyDelta, "Expected:", BURN_AMOUNT);
        
        bool matchesExpected = (aliceDelta == TRANSFER_AMOUNT) && 
                               (bobDelta == RECIPIENT_AMOUNT) &&
                               (supplyDelta == BURN_AMOUNT);
        
        if (matchesExpected) {
            console.log("Vulnerability not Exist: All state changes match expected behavior");
        } else {
            console.log("Vulnerability Exists: Unexpected state changes detected");
        }
    }

    function testTransferFromStateChanges() public {
        vm.prank(alice);
        caramel.approve(address(this), TRANSFER_AMOUNT);

        console.log("--- BEFORE-TransferFrom STATE ---");
        uint256 aliceBalanceBefore = caramel.balanceOf(alice);
        uint256 bobBalanceBefore = caramel.balanceOf(bob);
        uint256 totalSupplyBefore = caramel.totalSupply();
        console.log("Alice balance before:", aliceBalanceBefore);
        console.log("Bob balance before:", bobBalanceBefore);
        console.log("Total supply before:", totalSupplyBefore);

        console.log("--- TRIGGER TransferFrom ---");
        caramel.transferFrom(alice, bob, TRANSFER_AMOUNT);
        console.log("TransferFrom executed:", TRANSFER_AMOUNT, "tokens from Alice to Bob");

        console.log("--- AFTER-TransferFrom STATE ---");
        uint256 aliceBalanceAfter = caramel.balanceOf(alice);
        uint256 bobBalanceAfter = caramel.balanceOf(bob);
        uint256 totalSupplyAfter = caramel.totalSupply();
        console.log("Alice balance after:", aliceBalanceAfter);
        console.log("Bob balance after:", bobBalanceAfter);
        console.log("Total supply after:", totalSupplyAfter);
        
        console.log("--- STATE CHANGES ---");
        uint256 aliceDelta = aliceBalanceBefore - aliceBalanceAfter;
        uint256 bobDelta = bobBalanceAfter - bobBalanceBefore;
        uint256 supplyDelta = totalSupplyBefore - totalSupplyAfter;
        console.log("State Change: Alice balance decrease - Actual:", aliceDelta, "Expected:", TRANSFER_AMOUNT);
        console.log("State Change: Bob balance increase - Actual:", bobDelta, "Expected:", RECIPIENT_AMOUNT);
        console.log("State Change: Supply decrease - Actual:", supplyDelta, "Expected:", BURN_AMOUNT);
        
        bool matchesExpected = (aliceDelta == TRANSFER_AMOUNT) && 
                               (bobDelta == RECIPIENT_AMOUNT) &&
                               (supplyDelta == BURN_AMOUNT);
        
        if (matchesExpected) {
            console.log("Vulnerability not Exist: All state changes match expected behavior");
        } else {
            console.log("Vulnerability Exists: Unexpected state changes detected");
        }
    }
}