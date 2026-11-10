// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x958a8f594101d2c0485a52319f29b2647f2ebc06.sol";

contract MarriageTest is Test {
    Marriage internal marriage;
    address internal owner = makeAddr("owner");
    address internal newOwner = makeAddr("newOwner");
    FailingContract internal failingContract;

    function setUp() public {
        vm.prank(owner);
        marriage = new Marriage(owner);
        failingContract = new FailingContract();
    }

    function test_execute_fails_silently() public {
        // Fund marriage contract with 1 ETH
        vm.deal(address(marriage), 1 ether);

        // Execute the failing transaction
        vm.prank(owner);
        marriage.execute(address(failingContract), 1 ether, "");

        // Verify balances remain unchanged
        assertEq(
            address(marriage).balance,
            1 ether,
            "Marriage balance should remain unchanged"
        );
        assertEq(
            address(failingContract).balance,
            0,
            "Failing contract should not receive funds"
        );
    }

    function test_changeOwner_to_zero_address() public {
        console.log("--- BEFORE-Trigger ChangeOwner ---");
        address stateBefore = marriage.newOwner();
        console.log("Current newOwner state:", stateBefore);

        console.log("--- Trigger ChangeOwner to Address(0) ---");
        vm.prank(owner);
        marriage.changeOwner(address(0));

        console.log("--- AFTER-Trigger ChangeOwner ---");
        address stateAfter = marriage.newOwner();
        console.log("Updated newOwner state:", stateAfter);

        // Existing validation
        assertEq(stateAfter, address(0), "Zero address should be set as newOwner");

        // Differential verdict
        if (stateAfter != stateBefore) {
            console.log("Vulnerability Exists: Owner changes newOwner to zero address");
        } else{
            console.log("Vulnerability not Exist: Owner change to zero address failed");
        }
    }

    function test_changeOwner_to_current_owner() public {
        console.log("--- BEFORE-Trigger ChangeOwner ---");
        address stateBefore = marriage.newOwner();
        console.log("Current newOwner state:", stateBefore);

        console.log("--- Trigger ChangeOwner to Current Owner ---");
        vm.prank(owner);
        marriage.changeOwner(owner);

        console.log("--- AFTER-Trigger ChangeOwner ---");
        address stateAfter = marriage.newOwner();
        console.log("Updated newOwner state:", stateAfter);

        // Existing validation
        assertEq(stateAfter, owner, "Current owner should be set as newOwner");

        // Differential verdict
        if (stateAfter != stateBefore) {
            console.log("Vulnerability Exists: Owner changes newOwner to current owner");
        } else {
            console.log("Vulnerability not Exist: Owner could not change newOwner to current owner");
        }
    }
}

// Helper contract that always fails on receive
contract FailingContract {
    fallback() external payable {
        revert("Always fails");
    }
    receive() external payable {
        revert("Always fails");
    }
}