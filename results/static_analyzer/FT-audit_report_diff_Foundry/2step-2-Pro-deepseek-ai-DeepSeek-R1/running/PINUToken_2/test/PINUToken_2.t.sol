// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PINUToken.sol";

// Mock implementation for anti-bot and token interfaces
contract MockAntiBot {
    function setTokenOwner(address) public {}
}

contract MockRewardToken {
    function balanceOf(address) public pure returns (uint256) { 
        return 0; 
    }
}

contract PINUTokenWithdrawTest is Test {
    PINUToken token;
    MockAntiBot mockAntiBot;
    MockRewardToken mockRewardToken;
    
    address owner = address(0x1);
    address nonContractAddress;
    
    function setUp() public {
        mockAntiBot = new MockAntiBot();
        mockRewardToken = new MockRewardToken();
        
        // Create deterministic non-contract address
        nonContractAddress = makeAddr("nonContractAddress");
        
        vm.startPrank(owner);
        address[] memory emptyTokens = new address[](0);
        token = new PINUToken(
            address(mockAntiBot), 
            emptyTokens,
            address(mockRewardToken)
        );
        vm.stopPrank();
    }
    
    function testWithdrawTokenFailsOnNonContract() public {
        console.log("--- BEFORE-Trigger ---");
        console.log("State verification: No persistent state change expected before trigger");
        
        console.log("--- Trigger withdrawToken ---");
        bool success;
        vm.prank(owner);
        try token.withdrawToken(nonContractAddress) {
            success = true;
        } catch {
            success = false;
        }

        console.log("--- AFTER-Trigger ---");
        console.log("State verification: No persistent state change expected after trigger");
        
        if (success) {
            console.log("Vulnerability Exists: withdrawToken executed successfully on non-contract address");
        } else {
            console.log("Vulnerability not Exist: withdrawToken properly reverted on non-contract address");
        }
        
        // Test assertion remains for test framework
        assertTrue(!success, "withdrawToken should revert on non-contract address");
    }
}