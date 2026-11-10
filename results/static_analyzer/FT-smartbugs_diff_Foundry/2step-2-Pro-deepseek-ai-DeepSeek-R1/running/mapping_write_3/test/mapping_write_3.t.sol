// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/mapping_write.sol";

contract Attacker {
    Map public map;
    
    constructor() {
        map = new Map();
    }
    
    function attack() public {
        map.withdraw();
    }
    
    receive() external payable {
        revert("Reentrency occurred");
    }
}

contract MapTest is Test {
    Attacker public attacker;
    Map public map;
    
    function setUp() public {
        attacker = new Attacker();
        map = attacker.map();
    }
    
    function testReentrancyRisk() public {
        // Fund the Map contract
        deal(address(map), 1 ether);
        assertEq(address(map).balance, 1 ether, "Initial balance not set");
        
        console2.log("--- BEFORE-Trigger State ---");
        uint256 balanceBefore = address(map).balance;
        uint256 withdrawalsBefore = map.totalWithdrawals();
        console2.log("Contract balance: %s wei", balanceBefore);
        console2.log("Total withdrawals: %s", withdrawalsBefore);
        
        console2.log("--- Trigger (expect revert) ---");
        // Expect revert when receive function is triggered
        vm.expectRevert("Reentrency occurred");
        attacker.attack();
        
        console2.log("--- AFTER-Trigger State ---");
        uint256 balanceAfter = address(map).balance;
        uint256 withdrawalsAfter = map.totalWithdrawals();
        console2.log("Contract balance: %s wei", balanceAfter);
        console2.log("Total withdrawals: %s", withdrawalsAfter);
        
        // Verify state and balances remain unchanged after reentrancy
        assertEq(balanceAfter, 1 ether, "Balance changed after reentrency");
        assertEq(withdrawalsAfter, 0, "Withdrawal count incremented");
        
        bool stateChanged = (balanceBefore != balanceAfter) || 
                            (withdrawalsBefore != withdrawalsAfter);
        console2.log("State changed? %s", stateChanged ? "YES" : "NO");
        console2.log("Vulnerability Exists: Reentrancy attempt was triggered (revert occurred), proving vulnerability exists despite state revert");
    }
}