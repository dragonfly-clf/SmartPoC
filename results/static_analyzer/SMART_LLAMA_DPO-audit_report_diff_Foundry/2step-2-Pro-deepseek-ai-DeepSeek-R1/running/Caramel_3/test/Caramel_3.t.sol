// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Caramel.sol";

contract CaramelTest is Test {
    Caramel token;
    address owner = address(0x100);
    address alice = address(0x1);
    address bob = address(0x2);
    address charlie = address(0x3);

    function setUp() public {
        vm.startPrank(owner);
        token = new Caramel();
        token.transfer(alice, 100 * 1e18); // Owner to Alice - no burn
        vm.stopPrank();
    }

    function testTransferUpdatesTotalSupply() public {
        uint256 transferAmount = 100 * 1e18;
        uint256 expectedBurn = (transferAmount * 2) / 100; // 2% burn

        console.log("--- BEFORE-Trigger Transfer ---");
        uint256 totalBefore = token.totalSupply();
        console.log("Total supply before transfer: ", totalBefore);

        console.log("--- Trigger Transfer ---");
        vm.prank(alice);
        token.transfer(bob, transferAmount);

        console.log("--- AFTER-Trigger Transfer ---");
        uint256 totalAfter = token.totalSupply();
        console.log("Total supply after transfer:  ", totalAfter);

        uint256 actualBurn = totalBefore - totalAfter;
        console.log("Expected burn amount:        ", expectedBurn);
        console.log("Actual burn amount:          ", actualBurn);
        
        if (actualBurn == expectedBurn) {
            console.log("Vulnerability not Exist: Burn mechanism functions correctly in transfer");
        } else {
            console.log("Vulnerability Exists: Burn not applied correctly in transfer");
        }
    }

    function testTransferFromUpdatesTotalSupply() public {
        // Setup approval
        vm.prank(alice);
        token.approve(charlie, 1000 * 1e18);

        uint256 transferAmount = 100 * 1e18;
        uint256 expectedBurn = (transferAmount * 2) / 100; // 2% burn

        console.log("--- BEFORE-Trigger TransferFrom ---");
        uint256 totalBefore = token.totalSupply();
        console.log("Total supply before transferFrom: ", totalBefore);

        console.log("--- Trigger TransferFrom ---");
        vm.prank(charlie);
        token.transferFrom(alice, bob, transferAmount);

        console.log("--- AFTER-Trigger TransferFrom ---");
        uint256 totalAfter = token.totalSupply();
        console.log("Total supply after transferFrom:  ", totalAfter);

        uint256 actualBurn = totalBefore - totalAfter;
        console.log("Expected burn amount:            ", expectedBurn);
        console.log("Actual burn amount:              ", actualBurn);
        
        if (actualBurn == expectedBurn) {
            console.log("Vulnerability not Exist: Burn mechanism functions correctly in transferFrom");
        } else {
            console.log("Vulnerability Exists: Burn not applied correctly in transferFrom");
        }
    }
}