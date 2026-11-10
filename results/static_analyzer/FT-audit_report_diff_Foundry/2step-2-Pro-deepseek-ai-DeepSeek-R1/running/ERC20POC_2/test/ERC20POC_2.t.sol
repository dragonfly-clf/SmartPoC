// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {console} from "forge-std/console.sol"; // Added import for console logging
import "../src/ERC20POC.sol";

contract ERC20POCTest is Test {
    ERC20POC token;
    address owner = address(0x1);
    address staff1 = address(0x2);
    address user1 = address(0x3);
    uint256 initialSupply = 10000 * 10**18;

    function setUp() public {
        vm.startPrank(owner);
        token = new ERC20POC(
            0,                  // fee_rate
            initialSupply,      // locking_POC
            staff1,             // initial staff
            1000 * 10**18,      // staff locked POC
            0,                  // submit_daily_limit_total
            0                   // submit_daily_limit_personal
        );
        vm.stopPrank();
    }

    function testDoubleCancelReverts() public {
        bytes32 id = keccak256("test_reservation");
        uint256 reserveAmount = 500 * 10**18;
        
        // Staff reserves amount for user
        vm.startPrank(staff1);
        token.pegout_reserve(
            asSingletonArray(uint256(block.timestamp)),
            asSingletonBytes32Array(id),
            asSingletonAddressArray(user1),
            asSingletonUintArray(reserveAmount)
        );
        vm.stopPrank();

        // First cancellation (successful)
        vm.startPrank(staff1);
        token.pegout_reserve_cancel(asSingletonBytes32Array(id));
        vm.stopPrank();

        console.log("--- BEFORE SECOND CANCELLATION ---");
        // Check allowance and reservation state before second cancellation
        uint256 allowanceBeforeSecond = token.allowance(staff1, user1);
        ERC20POC.pegout_data memory reserveBeforeSecond = token.pegout_reserve_list(id);
        console.log("Allowance: %s", allowanceBeforeSecond);
        console.log("Reservation State: %s", uint(reserveBeforeSecond.state));

        console.log("--- TRIGGER: SECOND CANCELLATION (EXPECT REVERT) ---");
        // Attempt second cancellation (vulnerability trigger)
        vm.startPrank(staff1);
        vm.expectRevert("ERC20: decreased allowance below zero");
        token.pegout_reserve_cancel(asSingletonBytes32Array(id));
        vm.stopPrank();

        console.log("--- AFTER SECOND CANCELLATION ---");
        // Check allowance and reservation state after second cancellation
        uint256 allowanceAfterSecond = token.allowance(staff1, user1);
        ERC20POC.pegout_data memory reserveAfterSecond = token.pegout_reserve_list(id);
        console.log("Allowance: %s", allowanceAfterSecond);
        console.log("Reservation State: %s", uint(reserveAfterSecond.state));

        console.log("--- DIFFERENTIAL VERDICT ---");
        // Verify state remains unchanged after revert
        bool allowanceUnchanged = (allowanceBeforeSecond == allowanceAfterSecond);
        bool reservationStateUnchanged = (reserveBeforeSecond.state == reserveAfterSecond.state);
        console.log("Allowance unchanged: %s", allowanceUnchanged);
        console.log("Reservation state unchanged: %s", reservationStateUnchanged);

        if (allowanceUnchanged && reservationStateUnchanged) {
            console.log("Vulnerability Exists: Double cancellation causes allowance underflow reverts");
        } else {
            console.log("Vulnerability not Exist: State changed abnormally despite revert");
        }
    }

    // Helper functions to create singleton arrays
    function asSingletonArray(uint256 value) private pure returns (uint256[] memory) {
        uint256[] memory arr = new uint256[](1);
        arr[0] = value;
        return arr;
    }

    function asSingletonBytes32Array(bytes32 value) private pure returns (bytes32[] memory) {
        bytes32[] memory arr = new bytes32[](1);
        arr[0] = value;
        return arr;
    }

    function asSingletonAddressArray(address value) private pure returns (address[] memory) {
        address[] memory arr = new address[](1);
        arr[0] = value;
        return arr;
    }

    function asSingletonUintArray(uint256 value) private pure returns (uint256[] memory) {
        uint256[] memory arr = new uint256[](1);
        arr[0] = value;
        return arr;
    }
}