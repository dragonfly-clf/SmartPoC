// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/send_loop.sol";

contract RefunderTest is Test {
    Refunder refunder;
    address constant HARDCODED_ADDR1 = 0x79B483371E87d664cd39491b5F06250165e4b184;
    address constant HARDCODED_ADDR2 = 0x79B483371E87d664cd39491b5f06250165e4b185;

    function setUp() public {
        refunder = new Refunder();
    }

    function testConstructorSetsHardcodedAddresses() public {
        uint256 refundAddressesSlot = 0; // Assuming refundAddresses is first storage variable
        uint256 addrSlot1 = uint256(uint160(HARDCODED_ADDR1));
        uint256 addrSlot2 = uint256(uint160(HARDCODED_ADDR2));
        
        console.log("--- Storage Verification at Deployment ---");
        bytes32 slot0 = vm.load(address(refunder), bytes32(refundAddressesSlot));
        uint256 len = uint256(slot0);
        
        console.log("Checking refundAddresses array length (should be 2):", len);
        if (len != 2) {
            console.log("Vulnerability not Exist: RefundAddresses array length is not 2");
            fail();
            return;
        }

        bytes32 element0Slot = keccak256(abi.encode(refundAddressesSlot));
        bytes32 storedAddr1 = vm.load(address(refunder), element0Slot);
        console.log("Checking first address in array:", address(uint160(uint256(storedAddr1))));
        if (uint256(storedAddr1) != addrSlot1) {
            console.log("Vulnerability not Exist: First address not stored correctly");
            console.log("  Expected:", HARDCODED_ADDR1);
            console.log("  Actual  :", address(uint160(uint256(storedAddr1))));
            fail();
            return;
        }

        bytes32 element1Slot = bytes32(uint256(element0Slot) + 1);
        bytes32 storedAddr2 = vm.load(address(refunder), element1Slot);
        console.log("Checking second address in array:", address(uint160(uint256(storedAddr2))));
        if (uint256(storedAddr2) != addrSlot2) {
            console.log("Vulnerability not Exist: Second address not stored correctly");
            console.log("  Expected:", HARDCODED_ADDR2);
            console.log("  Actual  :", address(uint160(uint256(storedAddr2))));
            fail();
            return;
        }

        console.log("Vulnerability Exists: Hardcoded addresses are immutable and cannot be changed after deployment");
    }
}