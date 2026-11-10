// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/king_of_the_ether_throne.sol";

contract KingInputValidationTest is Test {
    KingOfTheEtherThrone throne;
    address constant WIZARD = address(0x1234);
    address attacker = address(0x9999);
    
    function setUp() public {
        vm.deal(WIZARD, 10 ether);
        vm.prank(WIZARD);
        throne = new KingOfTheEtherThrone();
        
        vm.deal(attacker, 10 ether);
    }

    function testEmptyNameClaim() public {
        uint256 claimPrice = throne.currentClaimPrice();
        
        // Get pre-trigger state
        console2.log("--- BEFORE-Trigger Monarch Snapshot ---");
        (, string memory preName, , ) = throne.currentMonarch();
        console2.log("Current monarch name (pre): ", preName);
        
        // Execute trigger operation
        console2.log("--- Trigger: claimThrone with empty string ---");
        vm.prank(attacker);
        throne.claimThrone{value: claimPrice}("");
        
        // Get post-trigger state
        console2.log("--- AFTER-Trigger Monarch Snapshot ---");
        (, string memory postName, , ) = throne.currentMonarch();
        console2.log("Current monarch name (post): ", postName);
        
        // Log verdict based on state validation
        if (bytes(postName).length == 0) {
            console2.log("VURABILITY VERIFIED: Empty name accepted - Vulnerability Exists");
            console2.log("Vulnerability Exists: Contract accepts empty names");
        } else {
            console2.log("VURABILITY REJECTED: Name must be non-empty - Vulnerability not Exist");
            console2.log("Vulnerability not Exist: Contract enforces name length validation");
        }
        
        // Additional existing assertion for test framework
        assertEq(postName, "", "Empty name should be accepted");
    }

    function testLongNameClaim() public {
        uint256 claimPrice = throne.currentClaimPrice();
        string memory longName = generateLongString(513);
        
        // Get pre-trigger state
        console2.log("--- BEFORE-Trigger Monarch Snapshot ---");
        (, string memory preName, , ) = throne.currentMonarch();
        console2.log("Current monarch name length (pre): ", bytes(preName).length);
        
        // Execute trigger operation
        console2.log("--- Trigger: claimThrone with 513-char name ---");
        vm.prank(attacker);
        throne.claimThrone{value: claimPrice}(longName);
        
        // Get post-trigger state
        console2.log("--- AFTER-Trigger Monarch Snapshot ---");
        (, string memory postName, , ) = throne.currentMonarch();
        uint256 postNameLength = bytes(postName).length;
        console2.log("Current monarch name length (post): ", postNameLength);
        
        // Log verdict based on state validation
        if (postNameLength > 256) {
            console2.log("VURABILITY VERIFIED: Name >256 chars accepted - Vulnerability Exists");
            console2.log("Vulnerability Exists: Contract allows names exceeding length limits");
        } else {
            console2.log("VURABILITY REJECTED: Name truncated to <=256 chars - Vulnerability not Exist");
            console2.log("Vulnerability not Exist: Contract enforces maximum name length");
        }
        
        // Additional existing assertion for test framework
        assertTrue(postNameLength > 256, "Excessively long name should be accepted");
    }
    
    function generateLongString(uint256 len) internal pure returns (string memory) {
        bytes memory longString = new bytes(len);
        for(uint i = 0; i < len; i++) {
            longString[i] = "a";
        }
        return string(longString);
    }
}