// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrance.sol";

contract ReentranceTest is Test {
    Reentrance reentrance;
    address attacker = makeAddr("attacker");

    function setUp() public {
        reentrance = new Reentrance();
        vm.deal(attacker, 2 ether);  // Fund attacker for donation
    }

    function testDonateBalancesOverflow() public {
        // Set attacker's balance to max uint256 - 1 via storage manipulation
        uint256 mappingSlot = 0; // Base slot for 'balances' mapping
        bytes32 balanceSlot = keccak256(abi.encode(uint256(uint160(attacker)), mappingSlot));
        vm.store(address(reentrance), balanceSlot, bytes32(type(uint256).max - 1));

        // Record pre-trigger state
        console.log("--- BEFORE-Trigger state ---");
        uint256 preBalance = reentrance.balanceOf(attacker);
        console.log("Attacker pre-balance:", preBalance);
        
        console.log("--- Trigger Donate (with 2 wei) ---");
        // Execute donation
        vm.prank(attacker);
        reentrance.donate{value: 2}(attacker);
        
        // Record post-trigger state
        console.log("--- AFTER-Trigger state ---");
        uint256 postBalance = reentrance.balanceOf(attacker);
        console.log("Attacker post-balance:", postBalance);
        
        // Vulnerability verdict
        bool vulnerabilityExists = (preBalance == type(uint256).max - 1) && (postBalance == 0);
        
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Balance overflowed from max-1 to 0");
        } else {
            console.log("Vulnerability not Exist: Balance overflow condition not met");
        }
    }
}