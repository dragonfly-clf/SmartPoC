// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/bsc.sol";

// Mock contracts with fixed address returns
contract MockRouter {
    function factory() external pure returns (address) {
        return address(0x3333333333333333333333333333333333333333);
    }
    
    function WETH() external pure returns (address) {
        return address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);
    }
}

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0x1111111111111111111111111111111111111111);
    }
}

contract BscIdUniquenessTest is Test {
    bsc public token;
    address owner = address(0x1);
    address user = address(0x2);

    function setUp() public {
        // Deploy mock contracts to fixed addresses
        vm.etch(address(0x10ED43C718714eb63d5aA57B78B54704E256024E), address(new MockRouter()).code);
        vm.etch(address(0x3333333333333333333333333333333333333333), address(new MockFactory()).code);
        
        // Deploy token contract as owner
        vm.startPrank(owner);
        token = new bsc();
        vm.stopPrank();
    }

    function testWritebcListDuplicateEntries() public {
        // Verify initial state
        console.log("--- BEFORE - First Blocklisting ---");
        assertFalse(token.isbcList(user));
        console.log("Initial block status: user NOT blocklisted");

        console.log("--- TRIGGER: First Blocklist Operation ---");
        vm.prank(owner);
        token.writebcList(user, true);
        console.log("Executed: writebcList(user, true)");

        console.log("--- AFTER - First Blocklisting ---");
        assertTrue(token.isbcList(user));
        console.log("Updated block status: user blocklisted");

        // Duplicate blocklisting (same value)
        console.log("\n--- BEFORE - Duplicate Blocklisting ---");
        bool prereqStatus = token.isbcList(user);
        console.log("Pre-existing block status:", prereqStatus ? "BLOCKED" : "UNBLOCKED");

        console.log("--- TRIGGER: Duplicate Blocklist Operation ---");
        vm.prank(owner);
        token.writebcList(user, true);
        console.log("Executed: duplicate writebcList(user, true)");

        console.log("--- AFTER - Duplicate Blocklisting ---");
        assertTrue(token.isbcList(user));
        console.log("Post-duplicate block status: user STILL blocklisted");

        // Set to false
        console.log("\n--- BEFORE - Unblock ---");
        assertTrue(token.isbcList(user));
        console.log("Pre-unblock status: user blocklisted");

        console.log("--- TRIGGER: Unblock Operation ---");
        vm.prank(owner);
        token.writebcList(user, false);
        console.log("Executed: writebcList(user, false)");

        console.log("--- AFTER - Unblock ---");
        assertFalse(token.isbcList(user));
        console.log("Updated block status: user unblocked");

        // Duplicate unblocklisting (same value)
        console.log("\n--- BEFORE - Duplicate Unblock ---");
        prereqStatus = token.isbcList(user);
        console.log("Pre-existing block status:", prereqStatus ? "BLOCKED" : "UNBLOCKED");

        console.log("--- TRIGGER: Duplicate Unblock Operation ---");
        vm.prank(owner);
        token.writebcList(user, false);
        console.log("Executed: duplicate writebcList(user, false)");

        console.log("--- AFTER - Duplicate Unblock ---");
        assertFalse(token.isbcList(user));
        console.log("Post-duplicate unblock status: user STILL unblocked");

        // Final verdict
        console.log("\nVulnerability Exists: Contract allows redundant blocklist operations without revert");
    }
}