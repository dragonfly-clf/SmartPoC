// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3a0e9acd953ffc0dd18d63603488846a6b8b2b01.sol";

contract TokenBankTest is Test {
    TokenBank tokenBank;
    address owner = address(0x1);
    address holder = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        vm.deal(owner, 10 ether); // Fund owner
        vm.stopPrank();
    }

    // Test unchecked low-level call in WithdrawToHolder
    function testUncheckedWithdrawToHolder() public {
        // Deposit funds first to create holder record
        vm.prank(owner);
        tokenBank.Deposit{value: 1 ether}();
        
        // Store initial contract balance
        uint256 initialContractBal = address(tokenBank).balance;
        uint256 initialHolderBalance = tokenBank.Holders(owner);

        console.log("--- BEFORE-Trigger Operation ---");
        console.log("Contract ETH Balance:", initialContractBal);
        console.log("Holder Balance:", initialHolderBalance);
        console.log("");

        // Simulate a contract that doesn't accept ether (no payable fallback)
        address nonPayableContract = address(new NonPayableContract());

        console.log("--- Trigger: WithdrawToHolder ---");
        // Attempt to withdraw to non-payable contract
        vm.prank(owner);
        tokenBank.WithdrawToHolder(nonPayableContract, 1 ether);
        console.log("");

        console.log("--- AFTER-Trigger Operation ---");
        uint256 contractBalAfter = address(tokenBank).balance;
        uint256 holderBalanceAfter = tokenBank.Holders(owner);
        console.log("Contract ETH Balance:", contractBalAfter);
        console.log("Holder Balance:", holderBalanceAfter);
        console.log("");

        // Validate state changes
        bool contractBalanceUnchanged = contractBalAfter == initialContractBal;
        bool holderBalanceReset = holderBalanceAfter == 0;
        bool vulnerabilityTriggered = contractBalanceUnchanged && holderBalanceReset;

        if (vulnerabilityTriggered) {
            console.log("Vulnerability Exists: Holder balance was reset to 0 despite failed ETH transfer");
        } else {
            console.log("Vulnerability not Exist: Unexpected state changes after operation");
        }

        // Existing assertions remain
        assertEq(contractBalAfter, initialContractBal, "Contract balance should remain unchanged");
        assertEq(holderBalanceAfter, 0, "Holder balance was incorrectly updated");
    }

    // Test unchecked low-level call in WithdrawToken
    function testUncheckedWithdrawToken() public {
        // Mock token that will fail transfers
        address failingToken = address(new FailingToken());

        vm.prank(owner);
        tokenBank.WithdrawToken(failingToken, 100, holder);

        // Test passes as long as it doesn't revert
        // No differential for token transfers per spec
    }

    // Test unchecked low-level call in WitdrawTokenToHolder
    function testUncheckedWitdrawTokenToHolder() public {
        // First deposit to create holder record
        vm.prank(owner);
        tokenBank.Deposit{value: 1 ether}();
        
        // Record pre-operation state
        uint256 initialEthBalance = address(tokenBank).balance;
        uint256 initialHolderBalance = tokenBank.Holders(owner);

        console.log("--- BEFORE-Trigger Operation ---");
        console.log("Contract ETH Balance:", initialEthBalance);
        console.log("Holder Balance:", initialHolderBalance);
        console.log("");

        // Mock token that will fail transfers
        address failingToken = address(new FailingToken());

        console.log("--- Trigger: WitdrawTokenToHolder ---");
        vm.prank(owner);
        tokenBank.WitdrawTokenToHolder(owner, failingToken, 100);
        console.log("");

        console.log("--- AFTER-Trigger Operation ---");
        uint256 postEthBalance = address(tokenBank).balance;
        uint256 postHolderBalance = tokenBank.Holders(owner);
        console.log("Contract ETH Balance:", postEthBalance);
        console.log("Holder Balance:", postHolderBalance);
        console.log("");

        // Validate state changes
        bool ethBalanceUnchanged = postEthBalance == initialEthBalance;
        bool holderBalanceReset = postHolderBalance == 0;
        bool vulnerabilityTriggered = ethBalanceUnchanged && holderBalanceReset;

        if (vulnerabilityTriggered) {
            console.log("Vulnerability Exists: Holder balance was reset to 0 despite failed token transfer");
        } else {
            console.log("Vulnerability not Exist: Unexpected state changes after operation");
        }

        // Verify holder balance was reset despite failed transfer
        assertEq(postHolderBalance, 0, "Holder balance was reset despite failed transfer");
    }
}

contract NonPayableContract {
    // No payable fallback function
    fallback() external {}
}

contract FailingToken {
    function transfer(address, uint256) external pure returns (bool) {
        return false; // Always fails
    }
}