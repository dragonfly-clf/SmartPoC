// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/insecure_transfer.sol";

contract IntegerOverflowAddTest is Test {
    IntegerOverflowAdd public token;
    address immutable owner = address(0x1);
    address immutable newOwner = address(0x2);
    address immutable user = address(0x3);

    function setUp() public {
        vm.startPrank(owner);
        token = new IntegerOverflowAdd();
        vm.stopPrank();
    }

    function test_OwnerCannotTransferOwnership() public {
        bool vulnerabilityExists = true;

        console.log("--- BEFORE-Trigger state ---");

        // Condition1: initial balance of owner = 0
        if (token.getBalance(owner) != 0) {
            console.log("FAIL: Condition1 - Initial balance of owner not 0");
            console.log(token.getBalance(owner));
            vulnerabilityExists = false;
        } else {
            console.log("PASS: Condition1");
        }

        // Condition2: owner can mint 100 tokens -> balance 100
        vm.prank(owner);
        try token.mint(owner, 100) {
            if (token.getBalance(owner) != 100) {
                console.log("FAIL: Condition2 - Owner mint 100 but balance not 100");
                console.log(token.getBalance(owner));
                vulnerabilityExists = false;
            } else {
                console.log("PASS: Condition2");
            }
        } catch {
            console.log("FAIL: Condition2 - Owner mint reverted");
            vulnerabilityExists = false;
        }

        // Condition3: non-owner (user) cannot mint
        vm.prank(user);
        try token.mint(user, 100) {
            console.log("FAIL: Condition3 - Non-owner was able to mint");
            vulnerabilityExists = false;
        } catch {
            console.log("PASS: Condition3");
        }

        console.log("--- Trigger: transferOwnership call ---");
        // Condition4: Attempt to call transferOwnership by non-owner (or anyone) should fail because function doesn't exist
        bytes memory callData = abi.encodeWithSignature("transferOwnership(address)", newOwner);
        (bool success, ) = address(token).call(callData);
        if (success) {
            console.log("FAIL: Condition4 - transferOwnership call succeeded");
            vulnerabilityExists = false;
        } else {
            console.log("PASS: Condition4");
        }

        console.log("--- AFTER-Trigger state ---");

        // Condition5: owner can mint again -> balance becomes 200
        vm.prank(owner);
        try token.mint(owner, 100) {
            if (token.getBalance(owner) != 200) {
                console.log("FAIL: Condition5 - Owner mint another 100 but balance not 200");
                console.log(token.getBalance(owner));
                vulnerabilityExists = false;
            } else {
                console.log("PASS: Condition5");
            }
        } catch {
            console.log("FAIL: Condition5 - Owner mint after transferOwnership call failed");
            vulnerabilityExists = false;
        }

        // Condition6: new owner cannot mint
        vm.prank(newOwner);
        try token.mint(newOwner, 100) {
            console.log("FAIL: Condition6 - New owner was able to mint");
            vulnerabilityExists = false;
        } catch {
            console.log("PASS: Condition6");
        }

        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Contract lacks ownership transfer function and the owner cannot relinquish control");
        } else {
            console.log("Vulnerability not Exist: Required conditions for the vulnerability were not satisfied");
        }
    }
}