// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x78c2a1e91b52bca4130b6ed9edd9fbcfd4671c37.sol";

contract WhaleGiveaway1Test is Test {
    WhaleGiveaway1 giveaway;
    address owner = address(0x1);
    address attacker = address(0x2);
    address failingContract;

    function setUp() public {
        vm.startPrank(owner);
        giveaway = new WhaleGiveaway1();
        vm.deal(owner, 1 ether);
        
        // Create a failing contract by deploying one without payable fallback
        failingContract = address(new FailingContract());
        vm.stopPrank();
    }

    function testUncheckedCallFailure() public {
        console2.log("--- BEFORE-Trigger Command Call ---");
        uint256 initialBalanceTarget = address(failingContract).balance;
        uint256 initialBalanceGiveaway = address(giveaway).balance;
        console2.log("Target contract balance before:", initialBalanceTarget);
        console2.log("Giveaway contract balance before:", initialBalanceGiveaway);

        console2.log("--- Trigger Command Call ---");
        vm.prank(owner);
        bytes memory data = "";
        giveaway.Command{value: 0.5 ether}(failingContract, data);

        console2.log("--- AFTER-Trigger Command Call ---");
        uint256 finalBalanceTarget = address(failingContract).balance;
        uint256 finalBalanceGiveaway = address(giveaway).balance;
        console2.log("Target contract balance after:", finalBalanceTarget);
        console2.log("Giveaway contract balance after:", finalBalanceGiveaway);

        // Compare state changes
        bool targetUnchanged = finalBalanceTarget == initialBalanceTarget;
        bool giveawayIncreased = finalBalanceGiveaway == initialBalanceGiveaway + 0.5 ether;
        
        if (targetUnchanged && giveawayIncreased) {
            console2.log("Vulnerability Exists: Call failed but ETH remains stuck in contract");
        } else {
            console2.log("Vulnerability not Exist: Either call succeeded or ETH was returned");
        }

        // Keep existing verification
        assertEq(finalBalanceTarget, initialBalanceTarget);
    }

    function testSuccessfulCall() public {
        address recipient = address(0x4);

        console2.log("--- BEFORE-Trigger Command Call ---");
        uint256 initialBalanceTarget = recipient.balance;
        uint256 initialBalanceGiveaway = address(giveaway).balance;
        console2.log("Recipient balance before:", initialBalanceTarget);
        console2.log("Giveaway contract balance before:", initialBalanceGiveaway);

        console2.log("--- Trigger Command Call ---");
        vm.prank(owner);
        bytes memory data = "";
        giveaway.Command{value: 0.5 ether}(recipient, data);

        console2.log("--- AFTER-Trigger Command Call ---");
        uint256 finalBalanceTarget = recipient.balance;
        uint256 finalBalanceGiveaway = address(giveaway).balance;
        console2.log("Recipient balance after:", finalBalanceTarget);
        console2.log("Giveaway contract balance after:", finalBalanceGiveaway);

        // Compare state changes
        bool targetIncreased = finalBalanceTarget == initialBalanceTarget + 0.5 ether;
        bool giveawayUnchanged = finalBalanceGiveaway == initialBalanceGiveaway;
        
        if (targetIncreased && giveawayUnchanged) {
            console2.log("Vulnerability not Exist: Call succeeded and ETH transferred");
        } else {
            console2.log("Unexpected behavior detected");
        }

        // Keep existing verification
        assertEq(finalBalanceTarget, initialBalanceTarget + 0.5 ether);
    }
}

contract FailingContract {
    // Non-payable fallback function that will revert on ETH transfers
    fallback() external {
        revert("This contract rejects ETH");
    }
}