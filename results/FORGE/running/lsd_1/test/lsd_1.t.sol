// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/LegendsDoge.sol";

contract LegendsDogeFeeTest is Test {
    LegendsDoge public token;
    address public owner = address(0x1);
    address public charity = address(0x2);

    function setUp() public {
        vm.startPrank(owner);
        token = new LegendsDoge(
            "LegendsDoge", 
            "LEGDOGE", 
            9, 
            1000000000, // 1 billion tokens
            5,          // 5% tx fee
            5,          // 5% burn fee
            5,          // 5% charity fee
            charity,
            owner
        );
        vm.stopPrank();
    }

    function test_feeManipulationExceedsLimit() public {
        console2.log("--- BEFORE-Trigger ---");
        console2.log("Preparing to update fee to 30%...");
        
        console2.log("--- Trigger FeeUpdate(30,30,30) ---");
        bool success;
        vm.startPrank(owner);
        try token.updateFee(30, 30, 30) {
            success = true;
        } catch {
            success = false;
        }
        vm.stopPrank();

        console2.log("--- AFTER-Trigger ---");
        if (success) {
            console2.log("Vulnerability Exists: Fee multiplier successfully set to 30% without restrictions");
        } else {
            console2.log("Vulnerability not Exist: Fee update reverted due to limit checks");
        }
    }
}