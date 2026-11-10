// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x19cf8481ea15427a98ba3cdd6d9e14690011ab10.sol";

contract UncheckedSendTest is Test {
    daoPOLSKAtokens token;
    address owner = makeAddr("owner");
    
    function setUp() public {
        vm.prank(owner);
        token = new daoPOLSKAtokens();
    }

    function testUncheckedSendVulnerability() public {
        // Fund the contract with 1 ether
        vm.deal(address(token), 1 ether);
        uint256 initialBalance = address(token).balance;
        
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Contract initial ETH balance (wei):", initialBalance);
        
        // Make owner a contract that reverts on Ether reception
        vm.etch(owner, hex"60006000fd");
        
        console2.log("--- Trigger Operation: PartialFundsTransfer ---");
        // Attempt unsafe ETH transfer
        vm.prank(owner);
        token.PartialFundsTransfer(0.5 ether);
        
        console2.log("--- AFTER-Trigger State ---");
        uint256 finalBalance = address(token).balance;
        console2.log("Contract final ETH balance (wei):", finalBalance);
        
        // Critical comparison: should remain unchanged if vulnerability exists
        if (initialBalance == finalBalance) {
            console2.log("Vulnerability Exists: ETH transfer failed silently, contract balance did not change - funds not recovered");
        } else {
            console2.log("Vulnerability not Exist: ETH transfer changed contract balance - funds recovered successfully");
        }
        
        // Verify contract balance remains unchanged (test assertion)
        assertEq(address(token).balance, initialBalance, "Balance should remain unchanged after failed transfer");
    }
}