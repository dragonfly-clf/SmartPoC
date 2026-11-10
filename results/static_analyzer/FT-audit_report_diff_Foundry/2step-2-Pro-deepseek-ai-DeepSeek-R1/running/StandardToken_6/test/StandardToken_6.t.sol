// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/StandardToken.sol";

contract MockRouter {
    address immutable _factory;
    
    constructor(address factory_) {
        _factory = factory_;
    }
    
    function factory() external view returns (address) {
        return _factory;
    }
}

contract MockFactory {
    address immutable _pair;
    
    constructor(address pair_) {
        _pair = pair_;
    }
    
    function createPair(address, address) external view returns (address) {
        return _pair;
    }
}

contract TestUnprotectedSetPair is Test {
    StandardToken public token;
    address constant owner = address(0x1000);
    address constant mockPair = address(0x3000);
    address constant HARDCODED_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        MockFactory mockFactory = new MockFactory(mockPair);
        MockRouter mockRouter = new MockRouter(address(mockFactory));
        
        // Override hardcoded router with mock
        vm.etch(HARDCODED_ROUTER, address(mockRouter).code);

        vm.startPrank(owner);
        token = new StandardToken(owner);
        vm.stopPrank();
    }

    function test_setPairAllowsArbitraryAddress() public {
        address testAddress = address(0x2000);
        
        console.log("--- BEFORE-Trigger setPair ---");
        bool isPairBefore = token.isPair(testAddress);
        console.log("isPair status for test address: %s", isPairBefore ? "true" : "false");
        assertFalse(isPairBefore, "Target address should not be pair initially");
        
        console.log("--- Trigger setPair (owner call) ---");
        vm.prank(owner);
        token.setPair(testAddress, true);
        
        console.log("--- AFTER-Trigger setPair ---");
        bool isPairAfter = token.isPair(testAddress);
        console.log("isPair status for test address: %s", isPairAfter ? "true" : "false");
        assertTrue(isPairAfter, "Target address should be marked as pair after set");
        
        if (isPairBefore != isPairAfter) {
            console.log("Vulnerability Exists: Owner can set arbitrary addresses as pairs");
        } else {
            console.log("Vulnerability not Exist: Failed to change isPair status");
        }
    }

    function test_setPairAllowsZeroAddress() public {
        address zeroAddress = address(0);

        console.log("--- BEFORE-Trigger setPair ---");
        bool isPairBefore = token.isPair(zeroAddress);
        console.log("isPair status for address(0): %s", isPairBefore ? "true" : "false");
        assertFalse(isPairBefore, "Zero address should not be pair initially");
        
        console.log("--- Trigger setPair (owner call) ---");
        vm.prank(owner);
        token.setPair(zeroAddress, true);
        
        console.log("--- AFTER-Trigger setPair ---");
        bool isPairAfter = token.isPair(zeroAddress);
        console.log("isPair status for address(0): %s", isPairAfter ? "true" : "false");
        assertTrue(isPairAfter, "Zero address should be marked as pair after set");
        
        if (isPairBefore != isPairAfter) {
            console.log("Vulnerability Exists: Owner can set zero address as pair");
        } else {
            console.log("Vulnerability not Exist: Failed to change isPair status");
        }
    }

    function test_setPairRevertsForNonOwner() public {
        address attacker = address(0xBAD00D);
        address attackerTarget = address(0x1);
        
        console.log("--- BEFORE-Trigger setPair ---");
        bool isPairBefore = token.isPair(attackerTarget);
        console.log("isPair status for target address: %s", isPairBefore ? "true" : "false");
        assertFalse(isPairBefore, "Target address should not be pair initially");
        
        console.log("--- Trigger setPair (non-owner call) ---");
        vm.prank(attacker);
        vm.expectRevert();
        token.setPair(attackerTarget, true);
        
        console.log("--- AFTER-Trigger setPair ---");
        bool isPairAfter = token.isPair(attackerTarget);
        console.log("isPair status for target address: %s", isPairAfter ? "true" : "false");
        assertFalse(isPairAfter, "Target address should still not be pair after failed call");
        
        if (isPairAfter) {
            console.log("Vulnerability Exists: Non-owner successfully changed pair status");
        } else {
            console.log("Vulnerability not Exist: Non-owner call reverted as expected");
        }
    }
}