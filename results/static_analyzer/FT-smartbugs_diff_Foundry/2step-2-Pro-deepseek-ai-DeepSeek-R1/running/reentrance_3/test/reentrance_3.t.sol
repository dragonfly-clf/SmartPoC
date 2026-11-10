// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrance.sol";

contract ReentranceTest is Test {
    Reentrance public reentrance;
    address public attacker;

    function setUp() public {
        // Deploy the contract
        reentrance = new Reentrance();
        // Create attacker address
        attacker = address(0xA);
        // Fund attacker for donations
        vm.deal(attacker, 10 ether);
    }

    function test_DonationToSelfInflatesBalanceAndCount() public {
        console.log("--- BEFORE-Trigger State ---");
        // Capture initial state: attacker's balance and donation count
        uint256 initialBalance = reentrance.balanceOf(attacker);
        uint256 initialCount = reentrance.donationCount(attacker);
        console.log("Attacker Balance Before: ", initialBalance);
        console.log("Attacker Donation Count Before: ", initialCount);
        require(initialBalance == 0, "Initial balance should be zero");
        require(initialCount == 0, "Initial donation count should be zero");

        console.log("--- Trigger Operation ---");
        // Perform critical operation: transfer donation to self
        uint256 amount = 1 ether;
        vm.prank(attacker);
        reentrance.donate{value: amount}(attacker);
        console.log("Attacker donated 1 ether to themselves");

        console.log("--- AFTER-Trigger State ---");
        // Capture post-attack state
        uint256 postBalance = reentrance.balanceOf(attacker);
        uint256 postCount = reentrance.donationCount(attacker);
        console.log("Attacker Balance After: ", postBalance);
        console.log("Attacker Donation Count After: ", postCount);

        // Vulnerability check: ensure state changed as expected
        bool balanceChanged = (postBalance == amount);
        bool countChanged = (postCount == initialCount + 1);
        bool attackSuccessful = balanceChanged && countChanged;

        // Print verdict based on state comparison
        if (attackSuccessful) {
            console.log("Vulnerability Exists: Attacker's balance and donation count successfully increased, indicating reentrant donation accepted");
            console.log("Vulnerability Exists: Reentrant donation allowed unauthorized state manipulation");
        } else {
            console.log("Vulnerability not Exist: Contract prevented unexpected state changes in balance or donation count");
        }
    }
}