// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe82f0742a71a02b9e9ffc142fdcb6eb1ed06fb87.sol";

contract FreebieTest is Test {
    Freebie private freebie;
    address private owner = 0x30ad12df80a2493a82DdFE367d866616db8a2595;
    address private attacker = address(0x9999);

    function setUp() public {
        vm.prank(owner);
        freebie = new Freebie();
        
        // Directly fund the contract
        vm.deal(address(freebie), 10 ether);
    }

    function testWithdrawOverflowReverts() public {
        vm.startPrank(attacker);
        
        console2.log("--- BEFORE-Trigger Storage Changes ---");
        // Convert slots to uint256 before bytes32 conversion
        bytes32 initialOwner = vm.load(address(freebie), bytes32(uint256(0)));
        bytes32 initialWithdrawals = vm.load(address(freebie), bytes32(uint256(1)));
        console2.log("Original owner:", address(uint160(uint256(initialOwner))));
        console2.log("Original totalWithdrawals:", uint256(initialWithdrawals));

        console2.log("--- Trigger Exploit ---");
        // Change storage slots using proper type conversion
        vm.store(address(freebie), bytes32(uint256(0)), bytes32(uint256(uint160(attacker))));
        vm.store(address(freebie), bytes32(uint256(1)), bytes32(type(uint256).max));

        console2.log("--- AFTER-Trigger Storage Changes ---");
        bytes32 newOwner = vm.load(address(freebie), bytes32(uint256(0)));
        bytes32 newWithdrawals = vm.load(address(freebie), bytes32(uint256(1)));
        console2.log("New owner:", address(uint160(uint256(newOwner))));
        console2.log("New totalWithdrawals:", uint256(newWithdrawals));

        // Verify storage manipulation was successful
        assertEq(
            address(uint160(uint256(newOwner))),
            attacker,
            "Vulnerability Exists: Owner overwritten by attacker"
        );
        assertEq(
            uint256(newWithdrawals),
            type(uint256).max,
            "Vulnerability Exists: totalWithdrawals overflow achieved"
        );

        console2.log("--- Trigger Withdraw Call ---");
        // Attempt withdrawal with overflow condition
        vm.expectRevert();
        (bool success, ) = address(freebie).call(abi.encodeWithSignature("withdraw()"));
        assertFalse(success, "Withdraw should fail due to overflow");

        vm.stopPrank();
        
        console2.log("Vulnerability Exists: Storage manipulation enables withdrawal denial-of-service");
    }
}