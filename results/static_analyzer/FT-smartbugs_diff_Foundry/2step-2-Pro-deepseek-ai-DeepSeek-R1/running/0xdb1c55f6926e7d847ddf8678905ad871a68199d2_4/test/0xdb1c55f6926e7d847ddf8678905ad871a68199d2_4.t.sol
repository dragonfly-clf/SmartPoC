// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xdb1c55f6926e7d847ddf8678905ad871a68199d2.sol";

contract FreeEthTest is Test {
    FreeEth public freeEth;
    address public owner = makeAddr("owner");
    address public hacker = makeAddr("hacker");

    function setUp() public {
        vm.startPrank(owner);
        freeEth = new FreeEth();
        vm.deal(owner, 1 ether);
        vm.deal(address(freeEth), 1 ether);
        vm.stopPrank();
    }

    function test_CommandAllowsZeroAddress() public {
        console.log("--- BEFORE-Trigger State ---");
        console.log("No state to record (vulnerability is about input validation)");

        console.log("--- Trigger Operation: Command with zero address ---");
        bool vulnerable;
        try freeEth.Command(address(0), bytes("malicious data")) {
            vulnerable = true;
        } catch {
            vulnerable = false;
        }

        console.log("--- AFTER-Trigger State ---");
        console.log("No state to record (input validation vulnerability has no state changes)");

        // Vulnerability verdict
        if (vulnerable) {
            console.log("Vulnerability Exists: Command executed without reverting when given zero address");
            assertTrue(vulnerable, "Vulnerability Exists: Zero address exploitation successful");
        } else {
            console.log("Vulnerability not Exist: Command reverted for zero address input as expected");
        }
    }

    function test_CommandAllowsEmptyData() public {
        console.log("--- BEFORE-Trigger State ---");
        console.log("No state to record (vulnerability is about input validation)");

        console.log("--- Trigger Operation: Command with empty data ---");
        bool vulnerable;
        try freeEth.Command(hacker, bytes("")) {
            vulnerable = true;
        } catch {
            vulnerable = false;
        }

        console.log("--- AFTER-Trigger State ---");
        console.log("No state to record (input validation vulnerability has no state changes)");

        // Vulnerability verdict
        if (vulnerable) {
            console.log("Vulnerability Exists: Command executed without reverting when given empty data");
            assertTrue(vulnerable, "Vulnerability Exists: Empty data exploitation successful");
        } else {
            console.log("Vulnerability not Exist: Command reverted for empty data input as expected");
        }
    }
}