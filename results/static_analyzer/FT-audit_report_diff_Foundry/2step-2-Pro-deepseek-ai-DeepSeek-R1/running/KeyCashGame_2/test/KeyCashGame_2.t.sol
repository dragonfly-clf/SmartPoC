// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KeyCashGame.sol";

contract KeyCashGameTest is Test {
    KeyCashGame public game;
    address public owner = address(0x1);
    address public nonOwner = address(0x2);

    function setUp() public {
        vm.prank(owner);
        game = new KeyCashGame();
    }

    function testSetParametersByOwner() public {
        vm.prank(owner);
        game.setIncreaseTimePerTicket(10);
    }

    function testSetParametersByNonOwner() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("Owner address:", owner);
        console.log("Non-owner address:", nonOwner);
        console.log("Attempting non-owner access to setIncreaseTimePerTicket");

        console.log("--- Trigger ---");
        bool callSucceeded;
        vm.startPrank(nonOwner);
        try game.setIncreaseTimePerTicket(10) {
            callSucceeded = true;
        } catch {
            callSucceeded = false;
        }
        vm.stopPrank();

        console.log("--- AFTER-Trigger ---");
        string memory verdict;
        
        if (callSucceeded) {
            console.log("OUTCOME: Non-owner access permitted");
            verdict = "Vulnerability Exists: Non-owner can bypass access control";
        } else {
            console.log("OUTCOME: Access control reverts non-owner call");
            verdict = "Vulnerability not Exist: Access control reverts non-owner calls";
        }
        
        console.log("FINAL VERDICT: %s", verdict);
    }
}