// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PINUToken.sol";

contract MockPinkAntiBot {
    function setTokenOwner(address) public {}
}

contract PINUTokenLPDuplicationTest is Test {
    PINUToken token;
    MockPinkAntiBot mockPinkAntiBot;
    address constant rewardToken = address(1); // Mock reward token

    function setUp() public {
        // Deploy mock PinkAntiBot contract
        mockPinkAntiBot = new MockPinkAntiBot();
        
        // Initialize with empty pair token array
        address[] memory pairTokens = new address[](0);
        
        // Deploy PINUToken with mocked dependencies
        token = new PINUToken(
            address(mockPinkAntiBot), 
            pairTokens, 
            rewardToken
        );
    }

    function test_DuplicateSetLpAddress() public {
        address ownerAddress = token.owner();
        address lpAddress = vm.addr(1); // Generated address for LP

        // First call to set LP address
        vm.prank(ownerAddress);
        token.setLpAddress(lpAddress, true);
        console.log("--- BEFORE-Trigger SetLpAddress ---");
        console.log("First setLpAddress call completed successfully");

        console.log("--- Trigger Duplicate SetLpAddress ---");
        bool duplicateSucceeded;
        
        // Attempt duplicate call using proper try-catch syntax
        vm.startPrank(ownerAddress);
        try token.setLpAddress(lpAddress, true) {
            duplicateSucceeded = true;
        } catch {
            duplicateSucceeded = false;
        }
        vm.stopPrank();

        console.log("--- AFTER-Trigger SetLpAddress ---");
        if (duplicateSucceeded) {
            console.log("Duplicate call executed without reverting");
            console.log("Vulnerability Exists: Duplicate setLpAddress call did not revert");
        } else {
            console.log("Duplicate call reverted");
            console.log("Vulnerability not Exist: Duplicate setLpAddress call reverted");
        }
    }
}