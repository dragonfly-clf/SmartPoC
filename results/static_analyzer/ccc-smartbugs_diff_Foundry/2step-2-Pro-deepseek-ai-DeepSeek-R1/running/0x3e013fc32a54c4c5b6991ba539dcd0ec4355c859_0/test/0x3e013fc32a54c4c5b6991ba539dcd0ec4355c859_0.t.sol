// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3e013fc32a54c4c5b6991ba539dcd0ec4355c859.sol";

contract MultiplicatorX4Test is Test {
    MultiplicatorX4 public multiplicator;
    address user = makeAddr("user");

    function setUp() public {
        multiplicator = new MultiplicatorX4();
    }

    function test_DenialOfServiceWhenContractEmpty() public {
        // Log before trigger
        console.log("--- BEFORE-Trigger ContractBalance ---");
        uint256 initialBalance = address(multiplicator).balance;
        console.log("Initial contract balance: ", initialBalance);
        assertEq(initialBalance, 0, "Contract must start empty");

        // Give user 1 ether for the transaction
        vm.deal(user, 1 ether);
        
        // Log trigger action
        console.log("--- Trigger Call (should revert) ---");
        
        // User's call should revert when contract is empty
        vm.prank(user);
        vm.expectRevert();
        multiplicator.multiplicate{value: 1 ether}(user);
        
        // Log after trigger
        console.log("--- AFTER-Trigger ContractBalance ---");
        uint256 finalBalance = address(multiplicator).balance;
        console.log("Final contract balance: ", finalBalance);
        assertEq(finalBalance, 0, "Contract must remain empty");
        
        // Final vulnerability verdict
        console.log("Vulnerability Exists: Contract reverts when empty, causing permanent DoS condition");
    }
}