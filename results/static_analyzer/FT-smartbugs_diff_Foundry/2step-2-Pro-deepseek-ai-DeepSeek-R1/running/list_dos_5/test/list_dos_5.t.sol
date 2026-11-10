// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/list_dos.sol";

contract GovernmentTest is Test {
    Government public gov;
    address public currentElite = address(this);
    address public nextGeneration = address(0x1234);
    address public attacker = address(0x5678);
    
    function setUp() public {
        gov = new Government{value: 0}();
    }

    function testNonCorruptEliteCannotChange() public {
        console2.log("--- BEFORE-Trigger corruptElite ---");
        address startingElite = gov.corruptElite();
        console2.log("Starting corrupt elite: ", startingElite);

        console2.log("--- Trigger Action: inheritToNextGeneration called by attacker ---");
        vm.prank(attacker);
        gov.inheritToNextGeneration(nextGeneration);

        console2.log("--- AFTER-Trigger corruptElite ---");
        address currentElite = gov.corruptElite();
        console2.log("Current corrupt elite: ", currentElite);

        if (currentElite != startingElite) {
            console2.log("Vulnerability Exists: Non-Elite successfully changed corruptElite");
        } else {
            console2.log("Vulnerability not Exist: Non-Elite could not change corruptElite, which is expected");
        }
        
        // Original assertion remains
        assertEq(gov.corruptElite(), startingElite, "Non-elite cannot change elite status");
    }

    function testCorruptEliteCanChangeSuccessfully() public {
        console2.log("--- BEFORE-Trigger corruptElite ---");
        address startingElite = gov.corruptElite();
        console2.log("Starting corrupt elite: ", startingElite);

        console2.log("--- Trigger Action: inheritToNextGeneration called by startingElite ---");
        vm.prank(startingElite);
        gov.inheritToNextGeneration(nextGeneration);

        console2.log("--- AFTER-Trigger corruptElite ---");
        address currentElite = gov.corruptElite();
        console2.log("Current corrupt elite: ", currentElite);

        if (currentElite == nextGeneration) {
            console2.log("Vulnerability not Exist: Corrupt elite successfully changed corruptElite");
        } else {
            console2.log("Vulnerability Exists: Corrupt elite cannot change corruptElite");
        }
        
        // Original assertions remain
        assertEq(gov.corruptElite(), nextGeneration, "Elite status not transferred");
        assertTrue(gov.corruptElite() != startingElite, "Previous elite should be replaced");
    }
}