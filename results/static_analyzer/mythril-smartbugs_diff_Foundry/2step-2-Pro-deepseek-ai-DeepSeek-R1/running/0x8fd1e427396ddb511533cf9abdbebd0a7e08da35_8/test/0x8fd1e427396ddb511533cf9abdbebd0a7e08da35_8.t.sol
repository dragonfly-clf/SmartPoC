// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x8fd1e427396ddb511533cf9abdbebd0a7e08da35.sol";

contract TokenBankTest is Test {
    TokenBank public tokenBank;

    // Valid Ethereum addresses for testing underflow/overflow conditions
    address private constant MAX_ADDRESS = address(type(uint160).max);
    address private constant MIN_ADDRESS = address(0);
    address private owner = makeAddr("owner");
    address private newOwner = makeAddr("newOwner");

    function setUp() public {
        vm.startPrank(owner);
        tokenBank = new TokenBank();
        tokenBank.changeOwner(newOwner);
        vm.stopPrank();
    }

    function testConfirmOwnerAddressMin() public {
        // Change newOwner to minimum address (simulates underflow condition)
        vm.prank(owner);
        tokenBank.changeOwner(MIN_ADDRESS);

        // Attempt confirmation from wrapped underflow address
        vm.prank(MIN_ADDRESS);
        tokenBank.confirmOwner();

        // Read owner directly from storage slot 0
        bytes32 slot0 = vm.load(address(tokenBank), bytes32(uint256(0)));
        address actualOwner = address(uint160(uint256(slot0)));
        
        // Verify owner was changed to min address
        assertEq(actualOwner, MIN_ADDRESS, "Owner should be MIN_ADDRESS");
        
        // Final vulnerability verdict
        console.log("Vulnerability Exists: Successfully changed owner to MIN_ADDRESS");
    }

    function testConfirmOwnerAddressMax() public {
        // Change newOwner to maximum address (simulates overflow condition)
        vm.prank(owner);
        tokenBank.changeOwner(MAX_ADDRESS);

        // Attempt confirmation from max address
        vm.prank(MAX_ADDRESS);
        tokenBank.confirmOwner();

        // Read owner directly from storage slot 0
        bytes32 slot0 = vm.load(address(tokenBank), bytes32(uint256(0)));
        address actualOwner = address(uint160(uint256(slot0)));
        
        // Verify owner was changed to max address
        assertEq(actualOwner, MAX_ADDRESS, "Owner should be MAX_ADDRESS");
        
        // Final vulnerability verdict
        console.log("Vulnerability Exists: Successfully changed owner to MAX_ADDRESS");
    }
}