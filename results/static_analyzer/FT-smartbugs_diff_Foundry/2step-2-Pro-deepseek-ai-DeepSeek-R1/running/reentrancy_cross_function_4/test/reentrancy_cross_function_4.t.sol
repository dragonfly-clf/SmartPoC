// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_cross_function.sol";

contract ReentrancyCrossFunctionTest is Test {
    Reentrancy_cross_function public reentrancyContract;
    address owner = address(0x1);
    address userA = address(0x2);
    address userB = address(0x3);
    address attacker = address(0x999);

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(userA, 10 ether);
        vm.deal(attacker, 10 ether);  // Fund attacker

        // Deploy contract
        reentrancyContract = new Reentrancy_cross_function();
        
        // Setup initial balances for both userA and attacker
        vm.prank(userA);
        reentrancyContract.deposit{value: 1 ether}();
        
        vm.prank(attacker);
        reentrancyContract.deposit{value: 1 ether}();  // Attacker deposits
    }

    function testUnauthorizedTransfer() public {
        // Verify initial state
        uint attackerInitialBalance = reentrancyContract.getBalance(attacker);
        uint userBInitialBalance = reentrancyContract.getBalance(userB);
        uint userABalance = reentrancyContract.getBalance(userA);
        
        assertEq(attackerInitialBalance, 1 ether, "Attacker should have deposited balance");
        assertEq(userBInitialBalance, 0, "UserB should have zero balance initially");
        assertEq(userABalance, 1 ether, "UserA should maintain initial balance");

        // Attacker performs transfer
        vm.prank(attacker);
        reentrancyContract.transfer(userB, 1 ether);

        // Verify final state
        uint attackerFinalBalance = reentrancyContract.getBalance(attacker);
        uint userBFinalBalance = reentrancyContract.getBalance(userB);
        
        assertEq(attackerFinalBalance, 0, "Attacker balance should be depleted");
        assertEq(userBFinalBalance, 1 ether, "UserB should receive attacker's funds");
        
        // 漏洞存在性结论
        console.log("Vulnerability Exists: transfer function lacks access control allowing anyone to transfer funds");
    }
}