// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/FindThisHash.sol";

contract FindThisHashTest is Test {
    address attacker = makeAddr("attacker");
    uint256 constant DEPLOYMENT_ETH_AMOUNT = 0.1 ether;

    function test_AnyoneCanDeployContract() public {
        // Fund attacker with enough ether to deploy
        vm.deal(attacker, DEPLOYMENT_ETH_AMOUNT);
        uint256 initialBalance = attacker.balance;
        
        console2.log("--- BEFORE-Trigger Deployment ---");
        console2.log("Attacker balance (wei): ", initialBalance);
        console2.log("Contract balance: not deployed");

        console2.log("--- Trigger Deployment ---");
        vm.prank(attacker);
        FindThisHash instance = new FindThisHash{value: DEPLOYMENT_ETH_AMOUNT}();

        console2.log("--- AFTER-Trigger Deployment ---");
        uint256 contractBalance = address(instance).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console2.log("Contract balance (wei): ", contractBalance);
        console2.log("Attacker balance after (wei): ", attackerBalanceAfter);

        bool ethTransferred = contractBalance == DEPLOYMENT_ETH_AMOUNT;
        bool attackerBalDecreased = attackerBalanceAfter == initialBalance - DEPLOYMENT_ETH_AMOUNT;
        
        if (ethTransferred && attackerBalDecreased) {
            console2.log("Vulnerability Exists: Attacker successfully deployed contract and transferred ETH");
        } else {
            console2.log("Vulnerability not Exist: ETH transfer verification failed");
        }
    }
}