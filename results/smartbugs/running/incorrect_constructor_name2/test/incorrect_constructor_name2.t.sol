// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/incorrect_constructor_name2.sol";

contract MissingTest is Test {
    Missing public missingContract;
    address owner = makeAddr("owner");
    address attacker = makeAddr("attacker");

    function setUp() public {
        vm.prank(owner);
        missingContract = new Missing();
    }

    function testOwnerCanWithdraw() public {
        // Send some ETH to the contract
        vm.deal(address(missingContract), 1 ether);
        assertEq(address(missingContract).balance, 1 ether);

        // Owner withdraws funds
        uint256 ownerBalanceBefore = owner.balance;
        vm.prank(owner);
        missingContract.withdraw();

        // Verify funds were withdrawn by owner
        assertEq(address(missingContract).balance, 0);
        assertEq(owner.balance, ownerBalanceBefore + 1 ether);
    }

    function testCannotWithdrawAsNonOwner() public {
        // Send some ETH to the contract
        vm.deal(address(missingContract), 1 ether);

        // Non-owner tries to withdraw - should fail
        vm.prank(attacker);
        vm.expectRevert();
        missingContract.withdraw();
    }

    function testGetUserBalance() public view {
        // Test getUserBalance function
        assertEq(missingContract.getUserBalance(owner), 0);
        assertEq(missingContract.getUserBalance(attacker), 0);
    }
    
    function testVulnerabilityVerdict() public {
        // Read storage slot 0 to determine owner status
        bytes32 slot0 = vm.load(address(missingContract), bytes32(0));
        address contractOwner = address(uint160(uint256(slot0)));
        console.log("Contract owner from storage:", contractOwner);
        
        if (contractOwner == address(0)) {
            console.log("Vulnerability Exists: Constructor didn't run due to typo, owner remains 0");
        } else {
            console.log("Vulnerability not Exist: Owner correctly set in constructor");
        }
    }
}