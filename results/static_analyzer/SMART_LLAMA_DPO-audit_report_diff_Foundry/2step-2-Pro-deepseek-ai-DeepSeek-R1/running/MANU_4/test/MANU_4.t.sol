// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/MANU.sol";

contract MockWETH {
    function deposit() public payable {}
    function withdraw(uint) public {}
}

contract MockFactory {
    function createPair(address, address) external returns (address) {
        return address(0x456);
    }
}

contract MockRouter {
    address private _factory;
    address private _weth;
    
    constructor(address factoryAddr, address wethAddr) public {
        _factory = factoryAddr;
        _weth = wethAddr;
    }
    
    function factory() external view returns (address) {
        return _factory;
    }
    
    function WETH() external view returns (address) {
        return _weth;
    }
}

contract MANUOwnershipTest is Test {
    MANU public token;
    address public owner = address(0x1);
    address public newOwner = address(0x2);
    
    // Helper function to get runtime code
    function getRuntimeCode(address a) public view returns (bytes memory code) {
        uint256 size;
        assembly {
            size := extcodesize(a)
        }
        code = new bytes(size);
        assembly {
            extcodecopy(a, add(code, 0x20), 0, size)
        }
    }

    function setUp() public {
        // Create mock contracts
        MockWETH mockWETH = new MockWETH();
        MockFactory mockFactory = new MockFactory();
        MockRouter mockRouter = new MockRouter(address(mockFactory), address(mockWETH));
        
        // Fix router address with mock code
        address routerAddress = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        bytes memory routerCode = getRuntimeCode(address(mockRouter));
        vm.etch(routerAddress, routerCode);
        
        // Initialize router storage
        vm.store(
            routerAddress, 
            bytes32(uint256(0)), 
            bytes32(uint256(uint160(address(mockFactory))))
        );
        vm.store(
            routerAddress, 
            bytes32(uint256(1)), 
            bytes32(uint256(uint160(address(mockWETH))))
        );
        
        // Deploy MANU token
        vm.prank(owner);
        token = new MANU();
    }

    function testCanLockForArbitraryLongPeriod() public {
        vm.startPrank(owner);

        // BEFORE: Capture contract state
        address preLockOwner = token.owner();
        uint256 preLockUnlockTime = token.getUnlockTime();

        console.log("--- BEFORE-Trigger Lock ---");
        console.log("Current Owner Address:", preLockOwner);
        console.log("Current Unlock Timestamp:", preLockUnlockTime);
        console.log("");

        // Trigger: Lock for 1000 years
        console.log("--- Trigger Lock ---");
        uint256 longTime = 1000 * 365 days;
        token.lock(longTime);
        console.log("Lock triggered with duration: 1000 years");
        console.log("");

        // AFTER: Capture updated contract state
        address postLockOwner = token.owner();
        uint256 postLockUnlockTime = token.getUnlockTime();

        console.log("--- AFTER-Trigger Lock ---");
        console.log("Updated Owner Address:", postLockOwner);
        console.log("Updated Unlock Timestamp:", postLockUnlockTime);
        console.log("");

        // State verification
        bool ownerChanged = (postLockOwner != preLockOwner);
        bool unlockTimeChanged = (postLockUnlockTime != preLockUnlockTime);
        bool ownerResetToZero = (postLockOwner == address(0));
        bool unlockTimeSet = (postLockUnlockTime == block.timestamp + longTime);

        console.log("State Change Analysis:");
        console.log("• Contract ownership changed? %s", ownerChanged ? "YES" : "NO");
        console.log("• Unlock timestamp changed? %s", unlockTimeChanged ? "YES" : "NO");
        console.log("• Ownership reset to zero? %s", ownerResetToZero ? "YES" : "NO");
        console.log("• Unlock time set correctly? %s", unlockTimeSet ? "YES" : "NO");
        console.log("");

        // Vulnerability verdict
        if (unlockTimeSet && ownerResetToZero) {
            console.log("Vulnerability Exists: Arbitrary lock period confirmed (1000-year lock)");
        } else {
            console.log("Vulnerability not Exist: Lock operation failed to change state as expected");
        }

        // Original assertions remain
        assertEq(postLockUnlockTime, block.timestamp + longTime, "Lock time not set correctly");
        assertEq(postLockOwner, address(0), "Owner should be reset during lock");
        vm.stopPrank();
    }

    // Other tests remain unchanged
    function testNewOwnerCanLockAfterTransfer() public {
        // Transfer ownership
        vm.prank(owner);
        token.transferOwnership(newOwner);
        
        // New owner locks immediately
        vm.prank(newOwner);
        token.lock(30 days);
        
        // Verify lock was successful
        assertEq(token.owner(), address(0), "Ownership not cleared");
        assertGt(token.getUnlockTime(), block.timestamp, "Invalid unlock time");
    }

    function testUnauthorizedUnlock() public {
        vm.startPrank(owner);
        token.lock(100);
        vm.stopPrank();
        
        // Non-owner unlock attempt
        vm.prank(address(0x3));
        vm.expectRevert("You don't have permission to unlock");
        token.unlock();
    }
    
    function testRelockAfterUnlock() public {
        vm.startPrank(owner);
        
        // Lock and unlock
        token.lock(100);
        vm.warp(block.timestamp + 101); // Fastforward
        token.unlock();
        
        // Relock immediately
        token.lock(100);
        uint256 lockTime = token.getUnlockTime();
        
        assertEq(lockTime, block.timestamp + 100, "Invalid relock time");
        vm.stopPrank();
    }
}