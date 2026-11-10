// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etherstore.sol";

contract EtherStoreTest is Test {
    EtherStore public store;
    address attacker = vm.addr(1);
    
    function setUp() public {
        store = new EtherStore();
        vm.deal(attacker, 1 ether);
    }

    function test_depositOverflowVulnerability() public {
        bytes32 balanceSlot = keccak256(abi.encode(attacker, uint256(2)));
        vm.store(
            address(store),
            balanceSlot,
            bytes32(type(uint256).max - 1)
        );

        // Record initial state for differential comparison
        console2.log("--- BEFORE-Trigger Deposit ---");
        uint256 userBalanceBefore = store.getUserBalance(attacker);
        uint256 contractBalanceBefore = store.getContractBalance();
        console2.log("Attacker balance before:", userBalanceBefore);
        console2.log("Contract balance before:", contractBalanceBefore);
        
        // Execute the deposit operation
        console2.log("--- Trigger Deposit ---");
        vm.prank(attacker);
        store.depositFunds{value: 2}();
        
        // Record final state for differential comparison
        console2.log("--- AFTER-Trigger Deposit ---");
        uint256 userBalanceAfter = store.getUserBalance(attacker);
        uint256 contractBalanceAfter = store.getContractBalance();
        console2.log("Attacker balance after:", userBalanceAfter);
        console2.log("Contract balance after:", contractBalanceAfter);
        
        // Perform differential comparison
        bool overflowDetected = 
            (userBalanceBefore == type(uint256).max - 1) && 
            (userBalanceAfter == 0);
        console2.log("Overflow occurred:", overflowDetected);

        // Final vulnerability verdict
        if (overflowDetected) {
            console2.log("Vulnerability Exists: Arithmetic overflow detected causing balance reset");
        } else {
            console2.log("Vulnerability not Exist: No balance overflow detected");
        }

        // Existing assertions
        assertEq(
            store.getUserBalance(attacker),
            0,
            "Balance should overflow to 0"
        );
        assertEq(
            store.getContractBalance(),
            2,
            "Contract should hold 2 wei after deposit"
        );
    }
}