// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/TeaToken.sol";

contract TeaTokenLockTest is Test {
    TeaToken token;
    address owner = address(0xABCD);
    address attacker = address(0x1337);
    
    // Real Pancake Router address that will be mocked
    address constant PANCAKE_ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        vm.startPrank(owner);
        
        // Mock external calls needed for token deployment
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSelector(0xc45a0155), // factory() selector
            abi.encode(address(0x1)) // Mock factory
        );
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSelector(0xad5c4648), // WETH() selector
            abi.encode(address(0xBB)) // Mock WETH
        );
        vm.mockCall(
            address(0x1), // Mock factory address
            abi.encodeWithSelector(0xc9c65396), // createPair() selector
            abi.encode(address(0xBE)) // Mock pair
        );
        
        // Deploy token contract with mocked dependencies
        token = new TeaToken();
        vm.stopPrank();
    }

    function testLockPrivilegeEscalation() public {
        // Differential state capture before lock trigger
        console.log("--- BEFORE-Trigger Lock ---");
        address ownerBeforeLock = token.owner();
        uint256 unlockTimeBeforeLock = token.geUnlockTime();
        console.log("Contract Owner:", ownerBeforeLock);
        console.log("Unlock Time:", unlockTimeBeforeLock);

        // Trigger lock operation
        console.log("--- Trigger Lock ---");
        vm.startPrank(owner);
        token.lock(365 days * 100);
        vm.stopPrank();
        console.log("Triggered lock for 100 years");

        // Differential state capture after lock trigger
        console.log("--- AFTER-Trigger Lock ---");
        address ownerAfterLock = token.owner();
        uint256 unlockTimeAfterLock = token.geUnlockTime();
        console.log("Contract Owner:", ownerAfterLock);
        console.log("Unlock Time:", unlockTimeAfterLock);

        // State change validation
        bool vulnerabilityConfirmed = 
            (ownerAfterLock == address(0)) && 
            (unlockTimeAfterLock > unlockTimeBeforeLock);

        console.log("--- Differential Validation ---");
        console.log("Owner change (%s -> %s):", ownerBeforeLock, ownerAfterLock,
            (ownerAfterLock == address(0)) ? "changed to zero" : "not reset"
        );
        console.log("Unlock time change (%s -> %s):", unlockTimeBeforeLock, unlockTimeAfterLock,
            (unlockTimeAfterLock > unlockTimeBeforeLock) ? "increased" : "not changed"
        );
        console.log("Vulnerability exploitation:", vulnerabilityConfirmed 
            ? "Successful - state changed as expected" 
            : "Failed - no state changes detected"
        );

        // Vulnerability verdict
        if (vulnerabilityConfirmed) {
            console.log("Vulnerability Exists: Lock function allows permanent control loss without owner reset capability");
        } else {
            console.log("Vulnerability not Exist: Lock function maintains owner control or fails to set unlock time");
        }

        // Continue existing test verification (unchanged)
        // Verify ownership reset and lock time set
        assertEq(ownerAfterLock, address(0), "Ownership not reset");
        assertGt(unlockTimeAfterLock, block.timestamp, "Lock period not set");
        
        // Attempting ownership transfer should fail
        vm.startPrank(owner);
        vm.expectRevert("Ownable: caller is not the owner");
        token.transferOwnership(attacker);
        vm.stopPrank();
        
        // Demonstrate indefinite lock by attempting to lock again (should fail)
        vm.warp(block.timestamp + 365 days); // Warp 1 year
        vm.expectRevert("Ownable: caller is not the owner");
        token.lock(365 days * 50); // Try to extend lock
    }
}