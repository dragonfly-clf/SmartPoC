// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SCIp.sol";

contract SCIp_PrivilegeEscalation_Test is Test {
    SCIp public token;
    address public immutable admin = vm.addr(1);
    address public constant user = 0x2B5AD5c4795c026514f8317c7a215E218DcCD6cF;

    function setUp() public {
        vm.prank(admin);
        token = new SCIp();
    }

    function test_AdminCanBlockAddressWithoutUnblocking_Test() public {
        // BEFORE-Trigger: Query initial blocked state
        console.log("--- BEFORE-Trigger ---");
        vm.prank(user);
        bool blockedBefore = token.isBlocked();
        console.log("Blocked status of user before blockAddress call:", blockedBefore);
        assertFalse(blockedBefore, "User should NOT be blocked initially");

        // Trigger: Admin blocks user
        console.log("--- Trigger BlockAddress ---");
        vm.prank(admin);
        token.blockAddress(user);

        // AFTER-Trigger: Query blocked state again
        console.log("--- AFTER-Trigger ---");
        vm.prank(user);
        bool blockedAfter = token.isBlocked();
        console.log("Blocked status of user after blockAddress call:", blockedAfter);
        assertTrue(blockedAfter, "User should be blocked after blockAddress");

        // Verify unBlockAddress function does NOT exist
        console.log("--- Checking Unblock Function ---");
        (bool unblockExists, ) = address(token).call(
            abi.encodeWithSignature("unBlockAddress(address)", user)
        );
        console.log("unBlockAddress function exists?", unblockExists ? "YES" : "NO");
        assertFalse(unblockExists, "unBlockAddress function should not exist");

        // FINAL VERDICT: Vulnerability exists if user blocked AND no unblock function
        if (blockedAfter && !unblockExists) {
            console.log("Vulnerability Exists: User permanently blocked without unblock function");
        } else {
            console.log("Vulnerability not Exist: User unblocked or unblock function available");
        }
    }
}