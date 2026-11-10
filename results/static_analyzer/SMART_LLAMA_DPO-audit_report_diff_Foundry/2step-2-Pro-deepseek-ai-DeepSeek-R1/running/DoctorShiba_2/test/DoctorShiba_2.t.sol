// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/DoctorShiba.sol";

contract DoctorShibaUniquenessTest is Test {
    DoctorShiba token;
    
    // Player addresses
    address owner = vm.addr(1);
    address alice = vm.addr(2);
    address bob = vm.addr(3);
    address mallory = vm.addr(4);
    address charlie = vm.addr(5);

    function setUp() public {
        vm.prank(owner);
        token = new DoctorShiba();
        
        // Mint tokens to test with
        vm.prank(owner);
        token.transfer(alice, 100 ether);
    }

    function test_IdUniquenessViolation() public {
        // Set newun to mallory address
        vm.prank(owner);
        token.transfernewun(mallory);

        // Approve Bob to spend Alice's tokens
        vm.prank(alice);
        token.approve(bob, 50 ether);

        console2.log("--- BEFORE-Trigger Transfer ---");
        uint256 aliceBalanceBefore = token.balanceOf(alice);
        uint256 charlieBalanceBefore = token.balanceOf(charlie);
        console2.log("Alice balance before transfer:", aliceBalanceBefore);
        console2.log("Charlie balance before transfer:", charlieBalanceBefore);

        console2.log("--- Trigger: Unauthorized Transfer ---");
        // Bob transfers from Alice to Charlie (not Mallory) - should be violating uniqueness
        vm.prank(bob);
        token.transferFrom(alice, charlie, 10 ether);

        console2.log("--- AFTER-Trigger Transfer ---");
        uint256 aliceBalanceAfter = token.balanceOf(alice);
        uint256 charlieBalanceAfter = token.balanceOf(charlie);
        console2.log("Alice balance after transfer:", aliceBalanceAfter);
        console2.log("Charlie balance after transfer:", charlieBalanceAfter);

        uint256 aliceDecrease = aliceBalanceBefore - aliceBalanceAfter;
        uint256 charlieIncrease = charlieBalanceAfter - charlieBalanceBefore;
        console2.log("Alice balance decrease:", aliceDecrease);
        console2.log("Charlie balance increase:", charlieIncrease);

        // Vulnerability assessment
        if (charlieIncrease == 10 ether && aliceDecrease == 10 ether) {
            console2.log("Vulnerability Exists: Transfer succeeded to non-newun address despite restrictions");
        } else {
            console2.log("Vulnerability not Exist: Transfer blocked to non-newun address");
        }
    }
}