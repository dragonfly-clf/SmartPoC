// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe4eabdca81e31d9acbc4af76b30f532b6ed7f3bf.sol";

contract HoneyTest is Test {
    Honey honey;
    address owner = address(0x1);
    address failingContract;

    function setUp() public {
        vm.startPrank(owner);
        honey = new Honey();
        // Fund the owner account instead of the contract
        vm.deal(owner, 10 ether);
        vm.stopPrank();
    }

    function testUncheckedLowLevelCall() public {
        // Deploy a contract that will fail when receiving ETH
        FailingContract failer = new FailingContract();
        failingContract = address(failer);

        uint initialOwnerBalance = owner.balance;
        // Record initial failing contract balance (expected 0)
        uint initialFailingContractBalance = failingContract.balance;
        uint sendAmount = 1 ether;

        // --- BEFORE-Trigger Call ---
        console.log("--- BEFORE-Trigger Call ---");
        console.log("Owner balance (wei):", initialOwnerBalance);
        console.log("Failing contract balance (wei):", initialFailingContractBalance);
        console.log("============================");

        // --- Trigger Command ---
        console.log("--- Trigger Command ---");
        // Simulate owner calling Command with ETH and failing contract
        vm.prank(owner);
        honey.Command{value: sendAmount}(failingContract, "");

        // --- AFTER-Trigger Call ---
        console.log("--- AFTER-Trigger Call ---");
        uint ownerBalanceAfter = owner.balance;
        uint failingContractBalanceAfter = failingContract.balance;
        console.log("Owner balance (wei):", ownerBalanceAfter);
        console.log("Failing contract balance (wei):", failingContractBalanceAfter);
        console.log("============================");

        // Calculate balance changes
        uint256 ownerLoss = initialOwnerBalance - ownerBalanceAfter;
        uint256 failingContractGain = failingContractBalanceAfter - initialFailingContractBalance;

        console.log("Owner ETH loss (wei):", ownerLoss);
        console.log("Failing contract ETH gain (wei):", failingContractGain);

        // Vulnerability conditions:
        bool fundsLost = ownerLoss == sendAmount;   // Owner precisely lost sendAmount
        bool notReceived = failingContractGain == 0;  // Failing contract received 0 ETH

        // Final vulnerability verdict
        if (fundsLost && notReceived) {
            console.log("Vulnerability Exists: Unchecked low-level call enabled irreversible ETH loss");
        } else {
            console.log("Vulnerability not Exist: ETH was properly handled during failed transaction");
        }

        // Original integrity checks remain
        assertEq(owner.balance, initialOwnerBalance - sendAmount);
        assertEq(failingContract.balance, 0);
    }
}

contract FailingContract {
    // This contract will reject any ETH transfers
    receive() external payable {
        revert("This contract rejects ETH");
    }
}