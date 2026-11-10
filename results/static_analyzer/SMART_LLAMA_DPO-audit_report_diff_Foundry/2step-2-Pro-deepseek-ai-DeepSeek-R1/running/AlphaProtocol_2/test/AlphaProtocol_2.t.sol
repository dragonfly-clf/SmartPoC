// SPDX-License-Identifier: MIT
pragma solidity 0.7.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/AlphaProtocol.sol";

contract MockContract {
    constructor() payable {}
}

contract AlphaProtocolBotBlacklistTest is Test {
    AlphaProtocol token;
    MockContract mockContract;
    address constant TREASURY = address(0x7c1a586f27423d021DF0cCbE306Db5f222fff55e);
    address constant HARDCODED_ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    
    function setUp() public {
        // Setup mock calls for router and factory
        address mockFactory = address(0xBEEF);
        address mockWETH = address(0xCAFE);
        address mockPair = address(0xDEAD);
        
        // Mock router factory and WETH calls
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSelector(0xc45a0155), // factory() selector
            abi.encode(mockFactory)
        );
        vm.mockCall(
            HARDCODED_ROUTER,
            abi.encodeWithSelector(0xad5c4648), // WETH() selector
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSelector(0xc9c65396), // createPair() selector
            abi.encode(mockPair)
        );

        // Deploy token
        token = new AlphaProtocol();
        
        // Transfer ownership to test contract
        vm.prank(TREASURY);
        token.transferOwnership(address(this));
        
        // Deploy mock contract for testing
        mockContract = new MockContract();
    }

    function testRedundantBotBlacklistUpdate() public {
        // Set initial blacklist
        token.setBotBlacklist(address(mockContract), true);
        assertTrue(token.blacklist(address(mockContract)));
        
        // Start differential check - BEFORE
        console.log("--- BEFORE Trigger setBotBlacklist (redundant) ---");
        bool statusBefore = token.blacklist(address(mockContract));
        console.log("Blacklist status before redundant set:", statusBefore);
        
        console.log("--- TRIGGER: setBotBlacklist with same value ---");
        // Set same value again (redundant operation)
        token.setBotBlacklist(address(mockContract), true);
        
        // AFTER operation check
        console.log("--- AFTER Trigger setBotBlacklist (redundant) ---");
        bool statusAfter = token.blacklist(address(mockContract));
        console.log("Blacklist status after redundant set:", statusAfter);
        
        // Final verdict
        if (statusAfter == statusBefore) {
            console.log("Vulnerability not Exist: State unchanged as expected for redundant set");
        } else {
            console.log("Vulnerability Exists: State changed unexpectedly during redundant set");
        }
    }

    function testFlipBotBlacklist() public {
        // Initial set to true
        token.setBotBlacklist(address(mockContract), true);
        assertTrue(token.blacklist(address(mockContract)));
        
        // Flip check - BEFORE flip to false
        console.log("--- BEFORE Trigger setBotBlacklist (flip) ---");
        bool statusBeforeFlip = token.blacklist(address(mockContract));
        console.log("Blacklist status before flip:", statusBeforeFlip);
        
        console.log("--- TRIGGER: setBotBlacklist to false ---");
        // Flip to false
        token.setBotBlacklist(address(mockContract), false);
        
        // AFTER flip check
        console.log("--- AFTER Trigger setBotBlacklist (flip) ---");
        bool statusAfterFlip = token.blacklist(address(mockContract));
        console.log("Blacklist status after flip:", statusAfterFlip);
        
        // Final verdict
        if (!statusAfterFlip && statusBeforeFlip) {
            console.log("Vulnerability not Exist: State changed correctly (true to false)");
        } else {
            console.log("Vulnerability Exists: Flip operation failed to change state");
        }
    }

    function testNonContractBlacklisting() public {
        address eoa = address(0x123);
        
        // BEFORE blacklist attempt
        console.log("--- BEFORE Trigger setBotBlacklist (non-contract) ---");
        bool statusBefore = token.blacklist(eoa);
        console.log("Initial blacklist status (non-contract):", statusBefore);
        
        console.log("--- TRIGGER: Attempt EOA blacklisting ---");
        // Attempt to blacklist EOA (expected revert)
        vm.expectRevert("only contract address, not allowed externally owned account");
        token.setBotBlacklist(eoa, true);
        
        // AFTER revert check
        console.log("--- AFTER Trigger setBotBlacklist (non-contract) ---");
        bool statusAfter = token.blacklist(eoa);
        console.log("Blacklist status after failed set:", statusAfter);
        
        // Final verdict
        if (statusAfter == statusBefore) {
            console.log("Vulnerability not Exist: State unchanged after revert");
        } else {
            console.log("Vulnerability Exists: State changed after EAO blacklist revert");
        }
    }

    function testOnlyOwner() public {
        address attacker = address(0x666);
        
        // BEFORE unauthorized attempt
        console.log("--- BEFORE Trigger setBotBlacklist (non-owner) ---");
        bool statusBefore = token.blacklist(address(mockContract));
        console.log("Initial blacklist status:", statusBefore);
        
        console.log("--- TRIGGER: Non-owner setBotBlacklist ---");
        // Non-owner call (expected revert)
        vm.prank(attacker);
        vm.expectRevert();
        token.setBotBlacklist(address(mockContract), true);
        
        // AFTER revert check
        console.log("--- AFTER Trigger setBotBlacklist (non-owner) ---");
        bool statusAfter = token.blacklist(address(mockContract));
        console.log("Blacklist status after failed set:", statusAfter);
        
        // Final verdict
        if (statusAfter == statusBefore) {
            console.log("Vulnerability not Exist: State unchanged after access control revert");
        } else {
            console.log("Vulnerability Exists: State changed after unauthorized access");
        }
    }
}