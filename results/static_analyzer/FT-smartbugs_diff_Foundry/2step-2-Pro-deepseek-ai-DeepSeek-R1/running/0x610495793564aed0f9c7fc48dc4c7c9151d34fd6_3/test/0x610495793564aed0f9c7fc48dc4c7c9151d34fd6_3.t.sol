// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x610495793564aed0f9c7fc48dc4c7c9151d34fd6.sol";

contract SimpleWalletTest is Test {
    SimpleWallet public wallet;
    MaliciousReceiver public maliciousReceiver;
    address public owner;
    uint256 initialBalance = 1 ether;
    uint256 sendAmount = 0.5 ether;
    
    event MoneySent(address indexed target, uint256 value);

    function setUp() public {
        owner = address(this);
        wallet = new SimpleWallet();
        vm.deal(address(wallet), initialBalance);
    }

    // Malicious contract that reverts in fallback function
    function deployMaliciousReceiver() public {
        maliciousReceiver = new MaliciousReceiver();
    }

    function test_sendMoneyRevertedCallStillEmitsEvent() public {
        deployMaliciousReceiver();

        console.log("--- BEFORE-Trigger Transaction ---");
        uint256 walletBalanceBefore = address(wallet).balance;
        uint256 receiverBalanceBefore = address(maliciousReceiver).balance;
        console.log("Wallet Balance Before Send: %s", walletBalanceBefore);
        console.log("Receiver Balance Before Send: %s", receiverBalanceBefore);

        console.log("--- Trigger Transaction ---");
        vm.expectEmit(true, true, true, true);
        emit MoneySent(address(maliciousReceiver), sendAmount);
        
        wallet.sendMoney(address(maliciousReceiver), sendAmount, "");

        console.log("--- AFTER-Trigger Transaction ---");
        uint256 walletBalanceAfter = address(wallet).balance;
        uint256 receiverBalanceAfter = address(maliciousReceiver).balance;
        console.log("Wallet Balance After Send: %s", walletBalanceAfter);
        console.log("Receiver Balance After Send: %s", receiverBalanceAfter);

        // Verify state remains unchanged
        bool stateUnchanged = (walletBalanceAfter == walletBalanceBefore) && 
                             (receiverBalanceAfter == receiverBalanceBefore);
        
        if (stateUnchanged) {
            console.log("Vulnerability Exists: MoneySent event emitted while balances unchanged");
        } else {
            console.log("Vulnerability not Exist: State changed as expected");
        }

        // Original assertions for completeness
        assertEq(
            address(maliciousReceiver).balance, 
            receiverBalanceBefore, 
            "Receiver balance should remain unchanged"
        );
        assertEq(
            address(wallet).balance, 
            walletBalanceBefore, 
            "Wallet balance should remain unchanged"
        );
    }
}

contract MaliciousReceiver {
    fallback() external payable {
        revert("MaliciousReceiver: always reverts");
    }
}