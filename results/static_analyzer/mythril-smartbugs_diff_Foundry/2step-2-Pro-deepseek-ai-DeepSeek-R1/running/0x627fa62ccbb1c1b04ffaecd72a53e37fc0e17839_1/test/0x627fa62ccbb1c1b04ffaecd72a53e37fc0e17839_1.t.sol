// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x627fa62ccbb1c1b04ffaecd72a53e37fc0e17839.sol";

contract TokenBankTest is Test {
    TokenBank public tokenBank;
    address public owner = address(0x5af);
    address public nonOwner = address(0xaaa);
    address public newOwner = address(0xbbb);

    // Function to read owner from storage (slot 0)
    function getTokenBankOwner() internal view returns (address ownerAddress) {
        bytes32 slot0;
        assembly {
            slot0 := sload(0)
        }
        ownerAddress = address(uint160(uint256(slot0)));
    }

    function setUp() public {
        // Deploy contract with real owner
        vm.prank(owner);
        tokenBank = new TokenBank();
    }

    function testOwnerChangeUnderflowVulnerability() public {
        // Store original owner for comparison
        address originalOwner = owner;
        
        console2.log("--- BEFORE-Trigger ---");
        address currentOwner = getTokenBankOwner();
        console2.log("Current owner: ", currentOwner);
        console2.log("Expected owner: ", originalOwner);

        // Simulate underflow condition by calling from non-owner
        vm.startPrank(nonOwner);
        
        console2.log("--- Trigger ChangeOwner ---");
        // Attempt ownership change while forcing underflow in ownership condition
        (bool success,) = address(tokenBank).call(
            abi.encodeWithSignature("changeOwner(address)", newOwner)
        );
        vm.stopPrank();

        console2.log("--- AFTER-Trigger ---");
        console2.log("Call success status: ", success);
        currentOwner = getTokenBankOwner();
        console2.log("Current owner: ", currentOwner);
        console2.log("Expected owner: ", originalOwner);

        // Vulnerability determination
        if (success && currentOwner == originalOwner) {
            console2.log("Vulnerability Exists: Non-owner call completed without revert but ownership remained unchanged");
        } else {
            console2.log("Vulnerability not Exist: Call either reverted or owner changed unexpectedly");
        }
    }
}