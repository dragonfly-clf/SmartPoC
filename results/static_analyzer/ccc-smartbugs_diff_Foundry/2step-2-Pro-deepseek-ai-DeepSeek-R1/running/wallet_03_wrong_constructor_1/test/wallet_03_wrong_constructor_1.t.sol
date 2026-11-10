// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_03_wrong_constructor.sol";

contract MaliciousContract {
    Wallet public wallet;
    uint256 public counter; // Storage variable to trigger high gas usage

    constructor(Wallet _wallet) payable {
        wallet = _wallet;
    }

    function deposit() public payable {
        wallet.deposit{value: msg.value}();
    }

    function withdraw(uint256 amount) public {
        wallet.withdraw(amount);
    }

    fallback() external payable {
        // Use more than 2300 gas by modifying storage
        counter++;
    }
}

contract Wallet_DenialOfServiceTest is Test {
    Wallet public wallet;
    MaliciousContract public maliciousContract;
    
    function setUp() public {
        wallet = new Wallet();
        maliciousContract = new MaliciousContract{value: 1 ether}(wallet);
        maliciousContract.deposit{value: 1 ether}();
    }

    function test_WithdrawDenialOfService() public {
        // ------ BEFORE TRIGGER STATE ------
        uint256 initialBalance = wallet.getBalance(address(maliciousContract));
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Malicious contract balance in wallet:", initialBalance);
        console2.log("Expected initial balance: 1 ether");
        assertEq(initialBalance, 1 ether, "Initial balance mismatch");
        
        // ------ TRIGGER OPERATION ------
        console2.log("\n--- Trigger Withdrawal Attempt ---");
        vm.expectRevert();
        maliciousContract.withdraw(1 ether);
        console2.log("Withdrawal attempted (expected to revert)");

        // ------ AFTER TRIGGER STATE ------
        console2.log("\n--- AFTER-Trigger State ---");
        uint256 finalBalance = wallet.getBalance(address(maliciousContract));
        console2.log("Malicious contract balance in wallet:", finalBalance);
        console2.log("Expected final balance: 1 ether");
        assertEq(finalBalance, 1 ether, "Balance should remain unchanged after failed withdrawal");

        // ------ VULNERABILITY VERDICT ------
        console2.log("\n--- Vuln Check Result ---");
        if (initialBalance == finalBalance) {
            console2.log("SUCCESS: Balance unchanged after withdrawal attempt");
            console2.log("Vulnerability Exists: Withdrawal failed due to gas consumption in malicious fallback");
        } else {
            console2.log("FAIL: Balance changed during withdrawal attempt");
            console2.log("Vulnerability not Exist: Withdrawal succeeded - No DOS detected");
        }
    }
}