// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BybetTokenERC20.sol";

contract BybetTokenTest is Test {
    BybetTokenERC20 token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);
    address mockPair1 = address(0x4);
    address mockPair2 = address(0x5);

    function setUp() public {
        vm.mockCall(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            abi.encodeWithSignature("factory()"),
            abi.encode(address(0x6))
        );
        
        vm.mockCall(
            address(0x10ED43C718714eb63d5aA57B78B54704E256024E),
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(0x7))
        );
        
        vm.mockCall(
            address(0x6),
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(0x8))
        );
        
        vm.startPrank(owner);
        token = new BybetTokenERC20();
        vm.stopPrank();
    }

    function testWhitelistUniqueness() public {
        bool vulnerabilityExists = false;
        
        vm.startPrank(owner);
        
        // Whitelist user1 initially
        token.setWhitelist(user1);

        console.log("--- BEFORE-Trigger Whitelist ---");
        bool user1Before = token.checkFeeExempt(user1);
        bool user2Before = token.checkFeeExempt(user2);
        console.log("user1 whitelisted:", user1Before);
        console.log("user2 whitelisted:", user2Before);
        
        console.log("--- Trigger: setWhitelist(user1) again ---");
        token.setWhitelist(user1);
        
        console.log("--- AFTER-Trigger Whitelist ---");
        bool user1After = token.checkFeeExempt(user1);
        bool user2After = token.checkFeeExempt(user2);
        console.log("user1 whitelisted:", user1After);
        console.log("user2 whitelisted:", user2After);
        
        // Check for unexpected state changes
        if (user1Before != user1After || user2Before != user2After) {
            if (user1Before != user1After) console.log("ERROR: user1 status changed unexpectedly");
            if (user2Before != user2After) console.log("ERROR: user2 status changed unexpectedly");
            vulnerabilityExists = true;
        }
        
        // Check correct final state
        if (!user1After) {
            console.log("ERROR: user1 not whitelisted after duplicate call");
            vulnerabilityExists = true; 
        }
        if (user2After) {
            console.log("ERROR: user2 whitelisted unexpectedly");
            vulnerabilityExists = true;
        }
        
        console.log("--- Verdict ---");
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: State corrupted by duplicate whitelist call");
        } else {
            console.log("Vulnerability not Exist: State remains valid after duplicate whitelist call");
        }
        
        vm.stopPrank();
    }

    function testAMMPairUniqueness() public {
        bool vulnerabilityExists = false;
        
        vm.startPrank(owner);
        
        // Set pair1 initially
        token.setAutomatedMarketMakerPair(mockPair1, true);
        
        console.log("Trigger 1: --- BEFORE-Trigger AMM Pair (true) ---");
        bool mockPair1Before = token.automatedMarketMakerPairs(mockPair1);
        console.log("mockPair1 status:", mockPair1Before);
        
        console.log("--- Trigger: setAutomatedMarketMakerPair(true) again ---");
        token.setAutomatedMarketMakerPair(mockPair1, true);
        
        console.log("--- AFTER-Trigger AMM Pair (true) ---");
        bool mockPair1After = token.automatedMarketMakerPairs(mockPair1);
        console.log("mockPair1 status:", mockPair1After);

        // Process other operations
        token.setAutomatedMarketMakerPair(mockPair2, true);
        token.setAutomatedMarketMakerPair(mockPair1, false);
        
        console.log("Trigger 2: --- BEFORE-Trigger AMM Pair (false) ---");
        mockPair1Before = token.automatedMarketMakerPairs(mockPair1);
        console.log("mockPair1 status:", mockPair1Before);
        
        console.log("--- Trigger: setAutomatedMarketMakerPair(false) again ---");
        token.setAutomatedMarketMakerPair(mockPair1, false);
        
        console.log("--- AFTER-Trigger AMM Pair (false) ---");
        mockPair1After = token.automatedMarketMakerPairs(mockPair1);
        console.log("mockPair1 status:", mockPair1After);
        
        // Validate states
        if (mockPair1Before != mockPair1After) {
            console.log("ERROR: State changed during duplicate AMM pair call");
            vulnerabilityExists = true;
        }
        if (token.automatedMarketMakerPairs(mockPair2) == false) {
            console.log("ERROR: mockPair2 unexpectedly modified");
            vulnerabilityExists = true;
        }
        
        console.log("--- Verdict ---");
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: State corrupted by duplicate AMM pair calls");
        } else {
            console.log("Vulnerability not Exist: State remains valid after duplicate AMM pair calls");
        }
        
        vm.stopPrank();
    }
}