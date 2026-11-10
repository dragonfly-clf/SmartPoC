// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import {console} from "forge-std/console.sol";
import "../src/send_loop.sol";

contract RefunderTest is Test {
    Refunder public refunder;
    address public revertingAddress = makeAddr("RevertingAddress");
    address public addr1 = makeAddr("Address1");
    address public addr2 = makeAddr("Address2");
    uint256 public refundAmount1 = 0.1 ether;
    uint256 public refundAmount2 = 0.2 ether;
    uint256 public totalRefundAmount = 0.4 ether; // 0.1 + 0.2 + 0.1

    function setUp() public {
        refunder = new Refunder();
        
        // Overwrite refundAddresses array length (slot 0)
        bytes32 arrayLengthSlot = bytes32(uint256(0));
        vm.store(address(refunder), arrayLengthSlot, bytes32(uint256(3)));
        
        // Calculate base storage slot for array elements
        bytes32 baseSlot = keccak256(abi.encode(uint256(0)));
        vm.store(address(refunder), baseSlot, bytes32(uint256(uint160(addr1))));
        vm.store(address(refunder), bytes32(uint256(baseSlot) + 1), bytes32(uint256(uint160(revertingAddress))));
        vm.store(address(refunder), bytes32(uint256(baseSlot) + 2), bytes32(uint256(uint160(addr2))));

        // Set refund amounts in mapping (slot 1)
        bytes32 slot;
        slot = keccak256(abi.encode(addr1, uint256(1)));
        vm.store(address(refunder), slot, bytes32(refundAmount1));
        slot = keccak256(abi.encode(revertingAddress, uint256(1)));
        vm.store(address(refunder), slot, bytes32(refundAmount2));
        slot = keccak256(abi.encode(addr2, uint256(1)));
        vm.store(address(refunder), slot, bytes32(refundAmount1));

        // Fund the contract
        deal(address(refunder), totalRefundAmount);
    }

    function test_refundAllRevertsWhenAddressFails() public {
        // Record state BEFORE refundAll
        console.log("--- BEFORE-Trigger Refund ---");
        uint256 addr1RefundBefore = refunder.refunds(addr1);
        uint256 addr2RefundBefore = refunder.refunds(addr2);
        uint256 revertingRefundBefore = refunder.refunds(revertingAddress);
        uint256 totalRefundedBefore = refunder.totalRefunded();
        uint256 contractBalanceBefore = address(refunder).balance;

        console.log("Address1 refund:", addr1RefundBefore);
        console.log("Address2 refund:", addr2RefundBefore);
        console.log("RevertingAddress refund:", revertingRefundBefore);
        console.log("Total refunded:", totalRefundedBefore);
        console.log("Contract balance:", contractBalanceBefore);

        // Configure reverting contract
        vm.etch(revertingAddress, hex"60006000fd");
        
        console.log("--- Trigger RefundAll ---");
        // Test for expected revert
        vm.expectRevert();
        refunder.refundAll();

        console.log("--- AFTER-Trigger Refund ---");
        // Record state AFTER refundAll
        uint256 addr1RefundAfter = refunder.refunds(addr1);
        uint256 addr2RefundAfter = refunder.refunds(addr2);
        uint256 revertingRefundAfter = refunder.refunds(revertingAddress);
        uint256 totalRefundedAfter = refunder.totalRefunded();
        uint256 contractBalanceAfter = address(refunder).balance;

        console.log("Address1 refund:", addr1RefundAfter);
        console.log("Address2 refund:", addr2RefundAfter);
        console.log("RevertingAddress refund:", revertingRefundAfter);
        console.log("Total refunded:", totalRefundedAfter);
        console.log("Contract balance:", contractBalanceAfter);

        // Verify state remains unchanged
        bool stateUnchanged = 
            addr1RefundBefore == addr1RefundAfter &&
            addr2RefundBefore == addr2RefundAfter &&
            revertingRefundBefore == revertingRefundAfter &&
            totalRefundedBefore == totalRefundedAfter &&
            contractBalanceBefore == contractBalanceAfter;

        console.log("\n--- VERDICT ---");
        console.log("State remained unchanged:", stateUnchanged ? "YES" : "NO");
        
        // Vulnerability conclusion
        if (stateUnchanged) {
            console.log("Vulnerability Exists: refundAll function reverts when one address fails");
        } else {
            console.log("Vulnerability not Exist: Unexpected state change occurred during revert");
        }
    }
}