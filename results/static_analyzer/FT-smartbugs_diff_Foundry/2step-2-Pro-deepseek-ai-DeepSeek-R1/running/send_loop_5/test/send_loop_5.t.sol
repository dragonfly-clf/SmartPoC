// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/send_loop.sol";

contract RefunderTest is Test {
    Refunder public refunder;
    address owner = address(0x79B483371E87d664cd39491b5F06250165e4b184);
    address attacker = address(0xBAD);

    function setUp() public {
        vm.deal(attacker, 1 ether);
        vm.startPrank(owner);
        refunder = new Refunder();
        vm.stopPrank();
    }

    function test_ArbitraryUserCanAddFunds() public {
        // Pre-trigger state
        console.log("--- BEFORE-Trigger state ---");
        uint256 preContractBalance = address(refunder).balance;
        uint256 preAttackerRefund = refunder.refunds(attacker);
        console.log("Contract ETH balance:", preContractBalance);
        console.log("Attacker refund balance:", preAttackerRefund);

        // Trigger action
        console.log("--- Trigger ArbitraryUserAddFunds ---");
        vm.startPrank(attacker);
        refunder.addFunds{value: 0.1 ether}();
        vm.stopPrank();

        // Post-trigger state
        console.log("--- AFTER-Trigger state ---");
        uint256 postContractBalance = address(refunder).balance;
        uint256 postAttackerRefund = refunder.refunds(attacker);
        console.log("Contract ETH balance:", postContractBalance);
        console.log("Attacker refund balance:", postAttackerRefund);

        // Differential validation
        uint256 contractBalanceDiff = postContractBalance - preContractBalance;
        uint256 attackerRefundDiff = postAttackerRefund - preAttackerRefund;
        console.log("Balance diffs - Contract:", contractBalanceDiff, "Attacker:", attackerRefundDiff);

        // Vulnerability verdict
        if (contractBalanceDiff == 0.1 ether && attackerRefundDiff == 0.1 ether) {
            console.log("Vulnerability Exists: Arbitrary user can add funds and update refunds");
        } else {
            console.log("Vulnerability not Exist: State changes do not match expected vulnerability pattern");
        }
    }
}