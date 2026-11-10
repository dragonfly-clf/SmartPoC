// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb11b2fed6c9354f7aa2f658d3b4d7b31d8a13b77.sol";

contract DepositProxyOwnershipTest is Test {
    DepositProxy depositProxy;
    address deployer = makeAddr("deployer");
    address newOwner = makeAddr("newOwner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(deployer, 1 ether);
        vm.prank(deployer);
        depositProxy = new DepositProxy{value: 1 ether}();
    }

    function testCanTransferOwnership() public {
        // Transfer ownership to new owner
        vm.prank(deployer);
        depositProxy.transferOwner(newOwner);
        
        // Verify ownership transfer using withdraw privilege
        vm.startPrank(newOwner);
        // Validate newOwner has privileges by doing test withdraw
        depositProxy.withdraw(0);
        vm.stopPrank();
    }

    function testNonOwnerCannotWithdraw() public {
        console.log("--- BEFORE-Trigger Balance ---");
        uint256 balanceBefore = address(depositProxy).balance;
        console.log("Contract balance before:", balanceBefore);

        console.log("--- Trigger Withdraw by Attacker---");
        // Non-owner attempts withdraw
        vm.startPrank(attacker);
        depositProxy.withdraw(1);
        vm.stopPrank();

        console.log("--- AFTER-Trigger Balance ---");
        uint256 balanceAfter = address(depositProxy).balance;
        console.log("Contract balance after:", balanceAfter);

        bool isVulnerable = (balanceBefore != balanceAfter);
        if (isVulnerable) {
            console.log("VULNERABILITY CONFIRMED: Account balance changed after attack");
            console.log("Vulnerability Exists: Attacker successdully withdrew funds");
        } else {
            console.log("NO VULNERABILITY: Account balance unchanged after attack");
            console.log("Vulnerability not Exist: Attacker cannot withdraw ETH from proxy");
        }

        // Verify balance unchanged
        assertEq(
            balanceAfter,
            balanceBefore,
            "Non-owner should not be able to withdraw"
        );
    }

    function testNonOwnerCannotTransfer() public {
        // Create reference to original owner
        vm.startPrank(deployer);
        // Verify original owner can withdraw
        depositProxy.withdraw(0);
        vm.stopPrank();

        // Attempt transfer by non-owner
        vm.prank(attacker);
        depositProxy.transferOwner(attacker);

        // Verify original ownership remains using privileges
        vm.startPrank(deployer);
        depositProxy.withdraw(0);
        vm.stopPrank();
    }
}