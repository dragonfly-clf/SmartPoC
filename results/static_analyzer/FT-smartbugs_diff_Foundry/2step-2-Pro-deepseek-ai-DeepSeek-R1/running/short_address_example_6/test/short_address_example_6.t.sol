// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/short_address_example.sol";

contract MyToken_TransactionFee_Test is Test {
    MyToken token;
    address owner = address(1);
    address nonOwner = makeAddr("nonOwner");

    function setUp() public {
        // Deploy as owner
        vm.startPrank(owner);
        token = new MyToken();
        vm.stopPrank();
    }

    function testInitialFee() public view {
        assertEq(token.transactionFee(), 10, "Initial fee should be hardcoded to 10");
    }

    function testNonOwnerCannotModifyFee() public {
        uint256 newFee = 30;
        
        // BEFORE: Record initial fee state
        console.log("--- BEFORE-Trigger Fee Query ---");
        uint256 feeBefore = token.transactionFee();
        console.log("Current transaction fee (before):", feeBefore);
        assertEq(feeBefore, 10, "Initial fee should be 10");

        console.log("--- Trigger Fee Modification: nonOwner attempts to set fee to %s ---", newFee);
        vm.prank(nonOwner);
        vm.expectRevert("Only owner can set fee");
        token.setTransactionFee(newFee);

        // AFTER: Query fee state again
        console.log("--- AFTER-Trigger Fee Query ---");
        uint256 feeAfter = token.transactionFee();
        console.log("Current transaction fee (after):", feeAfter);

        // Differential comparison and vulnerability verdict
        if (feeAfter != feeBefore) {
            console.log("Vulnerability Exists: Fee changed from %s to %s by nonOwner", feeBefore, feeAfter);
        } else {
            console.log("Vulnerability not Exist: Fee remains unchanged at %s after nonOwner action", feeAfter);
        }

        assertEq(feeAfter, 10, "Fee should remain hardcoded at 10");
    }
}