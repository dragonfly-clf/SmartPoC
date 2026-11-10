// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console.sol"; // Add console import for logging
import "../src/0x78c2a1e91b52bca4130b6ed9edd9fbcfd4671c37.sol";

contract WhaleGiveaway1Test is Test {
    WhaleGiveaway1 giveaway;
    address owner = address(0xBEEF);

    function setUp() public {
        vm.startPrank(owner);
        giveaway = new WhaleGiveaway1();
        vm.stopPrank();
    }

    // Test valid call to Command function
    function testValidCommand() public {
        address target = address(0xCAFE);
        bytes memory data = hex"1234";

        // Fund the owner and make call
        vm.deal(owner, 1 ether);
        vm.prank(owner);
        giveaway.Command{value: 0.1 ether}(target, data);
    }

    // Test call to zero address should succeed (vulnerability) with differential logging
    function testZeroAddressCall() public {
        bytes memory data = hex"1234";

        // Fund owner
        vm.deal(owner, 1 ether);
        uint256 prevBalance = address(0).balance;
        
        console.log("--- BEFORE-Trigger Command to Zero Address ---");
        console.log("Balance of address(0) (pre):", prevBalance);
        console.log("--- Trigger Command to Zero Address ---");

        // Execute call to zero address
        vm.prank(owner);
        giveaway.Command{value: 0.1 ether}(address(0), data);

        // Post-trigger state
        uint256 newBalance = address(0).balance;
        console.log("--- AFTER-Trigger Command to Zero Address ---");
        console.log("Balance of address(0) (post):", newBalance);
        
        // Differential verification
        uint256 balanceChange = newBalance - prevBalance;
        bool isExploited = (balanceChange == 0.1 ether);
        
        console.log("Balance change:", balanceChange);
        console.log("Vulnerability Exploited:", isExploited);
        if(isExploited) {
            console.log("Vulnerability Exists: Ether sent to zero address");
        } else {
            console.log("Vulnerability not Exist: No ether sent to zero address");
        }
    }

    // Test empty data call should succeed (vulnerability) with verdict log
    function testEmptyDataCall() public {
        address target = address(0xCAFE);
        bytes memory data;

        console.log("--- Trigger Command with Empty Data ---");
        
        // Execute call with empty data and check result
        vm.prank(owner);
        (bool success,) = address(giveaway).call(
            abi.encodeWithSignature("Command(address,bytes)", target, data)
        );
        
        // Vulnerability verdict
        if(success) {
            console.log("Vulnerability Exists: Empty data call succeeded (no revert)");
        } else {
            console.log("Vulnerability not Exist: Empty data call reverted");
        }
    }
}