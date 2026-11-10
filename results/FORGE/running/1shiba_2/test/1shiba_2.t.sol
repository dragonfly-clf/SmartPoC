// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ONE1SHIBA.sol";

contract StopTransactionsTest is Test {
    ONE1SHIBA token;
    address owner = address(0x1);
    address user1 = address(0x2);
    address user2 = address(0x3);
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address mockFactory = address(0x1234);
    address mockPair = address(0x5678);
    address mockWETH = address(0x9ABC);
    
    function setUp() public {
        // Create minimal valid contract bytecode with even hex length
        bytes memory mockRouterCode = hex"6000";
        vm.etch(PANCAKE_ROUTER, mockRouterCode);

        // Mock external contract calls
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy token after setting up mocks
        vm.startPrank(owner);
        token = new ONE1SHIBA();
        token.transfer(user1, 1000 ether);
        vm.stopPrank();
    }

    function testOwnerCanStopAllTransactions() public {
        // Record maxTxAmount before attack
        console.log("--- BEFORE-Trigger _maxTxAmount ---");
        uint256 maxTxBefore = token._maxTxAmount();
        console.log("Current maxTxAmount:", maxTxBefore);
        
        console.log("--- Trigger setMaxTxPercent(0) ---");
        // Attack: set max transaction amount to 0
        vm.prank(owner);
        token.setMaxTxPercent(0);
        
        // Record maxTxAmount after attack
        console.log("--- AFTER-Trigger _maxTxAmount ---");
        uint256 maxTxAfter = token._maxTxAmount();
        console.log("New maxTxAmount:", maxTxAfter);
        
        // Differential verification
        if (maxTxAfter == 0) {
            console.log("Differential Check: maxTxAmount CHANGED (0 set properly)");
        } else {
            console.log("Differential Check: maxTxAmount UNCHANGED (not set to 0)");
        }

        // Verify user1 has tokens
        uint256 user1Balance = token.balanceOf(user1);
        assertGt(user1Balance, 0, "User1 should have tokens");
        
        // Test user transaction is blocked
        vm.startPrank(user1);
        vm.expectRevert("Transfer amount exceeds the maxTxAmount.");
        token.transfer(user2, 1);
        vm.stopPrank();
        
        // Verify owner can bypass transaction stop
        vm.prank(owner);
        token.transfer(user2, 1000 ether);
        uint256 user2Balance = token.balanceOf(user2);
        assertEq(user2Balance, 1000 ether, "Owner should bypass maxTx");
        
        // Final vulnerability verdict
        if (maxTxAfter == 0) {
            console.log("Vulnerability Exists: Owner can set maxTxAmount to 0 and block transactions");
        } else {
            console.log("Vulnerability not Exist: maxTxAmount not modified by setMaxTxPercent(0)");
        }
    }
}