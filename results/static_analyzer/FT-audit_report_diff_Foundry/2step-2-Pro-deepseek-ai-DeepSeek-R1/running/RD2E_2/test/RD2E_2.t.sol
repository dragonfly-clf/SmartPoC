// SPDX-License-Identifier: MIT
pragma solidity 0.8.1;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/RD2E.sol";

contract RevertingToken {
    function transfer(address, uint256) external pure returns (bool) {
        revert();
    }
}

contract RD2ELowLevelCallTest is Test {
    RD2E public rd2e;
    RevertingToken public revertingToken;
    address owner;

    function setUp() public {
        rd2e = new RD2E();
        revertingToken = new RevertingToken();
        owner = address(this);
    }

    function test_LowLevelCallRevertMessage() public {
        console.log("--- BEFORE-Trigger ---");
        // No state variables to check before the trigger
        
        console.log("--- Trigger Withdrawal ---");
        vm.prank(owner);
        try rd2e.withdrawalStuck(address(revertingToken), 1) {
            console.log("--- AFTER-Trigger ---");
            console.log("Result did not revert");
            console.log("Vulnerability Exists: Withdrawal should revert but completed successfully");
        } catch Error(string memory reason) {
            console.log("--- AFTER-Trigger ---");
            console.log("Revert string: '%s'", reason);
            if (keccak256(abi.encodePacked(reason)) == keccak256(abi.encodePacked("SafeERC20: low-level call failed"))) {
                console.log("Vulnerability not Exist: Revert message matches expected 'SafeERC20: low-level call failed'");
            } else {
                console.log("Vulnerability Exists: Revert message mismatch (expected: 'SafeERC20: low-level call failed', actual: '%s')", reason);
            }
        } catch (bytes memory) {
            console.log("--- AFTER-Trigger ---");
            console.log("Vulnerability Exists: Revert without expected string message");
        }
    }
}