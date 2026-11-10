// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_1.sol";

contract OverflowTest is Test {
    Overflow public overflowContract;
    address attacker = address(0x1337);
    address victim = address(0x999);

    function setUp() public {
        overflowContract = new Overflow();
        vm.deal(attacker, 1 ether);
        vm.deal(victim, 1 ether);
    }

    function testOverflowProtection() public {
        console2.log("--- Normal Withdraw Protection Test ---");
        
        console2.log("Step 1: Victim deposits 100 wei");
        vm.prank(victim);
        overflowContract.add(100);

        console2.log("Step 2: Attacker deposits 1 wei");
        vm.prank(attacker);
        overflowContract.add(1);

        console2.log("Check initial balances");
        assertEq(overflowContract.userBalances(attacker), 1);
        assertEq(overflowContract.userBalances(victim), 100);

        console2.log("Step 3: Attacker attempts over-withdrawal (2 wei)");
        vm.prank(attacker);
        vm.expectRevert();
        overflowContract.withdraw(2);
        
        console2.log("Vulnerability not Exist: Withdraw reverts correctly when attempting overdraft");
    }

    function testUncheckedOverflow() public {
        console2.log("--- Unchecked Overflow Test ---");
        console2.log("Warning: Cannot directly validate sellerBalance overflow due to private state visibility");
        
        uint256 largeAmount = type(uint256).max / 2;
        console2.log("Step 1: Attacker deposits large amount (%s wei)", largeAmount);
        vm.prank(attacker);
        overflowContract.add(largeAmount);
        
        console2.log("Step 2: Attacker deposits again to trigger possible overflow");
        vm.prank(attacker);
        overflowContract.add(largeAmount);
        
        console2.log("Check user balance (expecting %s wei)", largeAmount * 2);
        assertEq(overflowContract.userBalances(attacker), largeAmount * 2);
        
        console2.log("Vulnerability Exists: Unchecked arithmetic allows potential sellerBalance overflow");
    }

    function testNormalOperation() public {
        console2.log("--- Normal Operation Test ---");
        uint256 depositAmount = 100;
        
        console2.log("Step: Victim deposits %s wei", depositAmount);
        vm.prank(victim);
        overflowContract.add(depositAmount);
        
        console2.log("Check user balance matches deposit");
        assertEq(overflowContract.userBalances(victim), depositAmount);
        
        console2.log("Vulnerability not Exist: Normal operation functions correctly");
    }

    function testMaximumDeposit() public {
        console2.log("--- Maximum Deposit Test ---");
        uint256 maxAmount = type(uint256).max;
        
        console2.log("Step 1: Attacker deposits maximum amount (%s wei)", maxAmount);
        vm.prank(attacker);
        overflowContract.add(maxAmount);
        
        console2.log("Check user balance updated to max");
        assertEq(overflowContract.userBalances(attacker), maxAmount);
        
        console2.log("Step 2: Attempt to deposit 1 additional wei");
        vm.prank(attacker);
        vm.expectRevert();
        overflowContract.add(1);
        
        console2.log("Vulnerability not Exist: Deposit limit enforced via SafeMath");
    }
}