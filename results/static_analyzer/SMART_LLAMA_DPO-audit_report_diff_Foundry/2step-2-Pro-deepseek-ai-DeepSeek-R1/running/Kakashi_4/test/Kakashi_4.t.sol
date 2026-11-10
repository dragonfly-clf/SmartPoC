// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Kakashi.sol";

contract KakashiLockTest is Test {
    Kakashi public token;
    address owner = address(0x123);
    address constant ROUTER_ADDR = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    uint256 constant LOCK_PERIOD = 7 days;
    address mockFactory = address(0x123456);
    address mockWETH = address(0xabc);
    address mockPair = address(0xdef);
    address public initialOwner; // 儲存鎖定前的所有權狀態

    function setUp() public {
        // Mock router factory call
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );
        // Mock router WETH call
        vm.mockCall(
            ROUTER_ADDR,
            abi.encodeWithSignature("WETH()"),
            abi.encode(mockWETH)
        );
        // Mock factory createPair
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy token as owner
        vm.startPrank(owner);
        token = new Kakashi();
        initialOwner = token.owner(); // 紀錄鎖定前的所有者
        token.lock(LOCK_PERIOD);
        vm.stopPrank();
    }

    function testAfterLockOwnerIsZero() public {
        console.log("--- BEFORE-Trigger Lock ---");
        console.log("Initial owner state: ", initialOwner);
        console.log("Expected owner address: ", owner);
        
        console.log("--- Trigger Lock (occurred in setUp) ---");
        
        console.log("--- AFTER-Trigger Lock ---");
        address postLockOwner = token.owner();
        console.log("Final owner state: ", postLockOwner);
        console.log("Expected owner state: ", address(0));
        
        // 驗證所有權狀態變化
        bool vulnerabilityExists = postLockOwner != address(0);
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Ownership not properly reset after lock");
        } else {
            console.log("Vulnerability not Exist: Ownership reset to zero as expected");
        }
        
        // 保持原有測試邏輯
        assertEq(postLockOwner, address(0));
    }

    function testCannotUnlockPrematurely() public {
        // Advance time to just before lock expiry
        vm.warp(block.timestamp + LOCK_PERIOD - 1);
        
        vm.prank(owner);
        vm.expectRevert("Contract is locked until 7 days");
        token.unlock();
    }

    function testCanUnlockAfterLockPeriod() public {
        // Advance time beyond lock period
        vm.warp(block.timestamp + LOCK_PERIOD + 1);
        
        vm.prank(owner);
        token.unlock();
        
        assertEq(token.owner(), owner);
    }

    function testCannotUnlockByNonPreviousOwner() public {
        // Advance time beyond lock period
        vm.warp(block.timestamp + LOCK_PERIOD + 1);
        
        address attacker = address(0x666);
        vm.prank(attacker);
        vm.expectRevert("You don't have permission to unlock");
        token.unlock();
    }

    function testCannotLockAgainAfterLock() public {
        vm.prank(owner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.lock(LOCK_PERIOD);
    }
}