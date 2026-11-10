// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/SHIBI.sol";

contract SHIBILockTest is Test {
    SHIBI public token;
    
    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant MOCK_FACTORY = address(0x0123456789ABCDEF);
    address constant MOCK_WETH = address(0x9876543210ABCDEF);

    function setUp() public {
        // Mock UniSwap router and factory interactions
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(MOCK_FACTORY)
        );
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("WETH()"),
            abi.encode(MOCK_WETH)
        );
        vm.mockCall(
            MOCK_FACTORY,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(address(0x1111111111111111111111111111111111111111))
        );
        
        // Deploy contract
        token = new SHIBI();
    }

    function test_InfiniteLock() public {
        // Verify initial owner is deployer
        address deployer = token.owner();
        assertEq(deployer, address(this));
        
        // Take pre-lock state snapshots
        console.log("--- BEFORE-Trigger State ---");
        address preOwner = token.owner();
        uint preUnlockTime = token.geUnlockTime();
        console.log("Pre-lock owner: %s", preOwner);
        console.log("Pre-lock unlock time: %s", preUnlockTime);

        // Calculate long lock duration (1000 years)
        uint LOCK_DURATION = 1000 * 365 days;
        
        console.log("--- Trigger Lock Operation ---");
        // Perform the lock action
        token.lock(LOCK_DURATION);
        
        // Take post-lock state snapshots
        console.log("--- AFTER-Trigger State ---");
        address postOwner = token.owner();
        uint postUnlockTime = token.geUnlockTime();
        uint expectedUnlock = block.timestamp + LOCK_DURATION;
        console.log("Post-lock owner: %s", postOwner);
        console.log("Post-lock unlock time: %s", postUnlockTime);
        console.log("Expected unlock time: %s", expectedUnlock);

        // Validate state changes
        console.log("--- Vulnerability Verification ---");
        bool ownerChanged = (preOwner != postOwner);
        bool unlockedTimeChanged = (preUnlockTime != postUnlockTime);
        bool unlockTimeCorrect = (postUnlockTime == expectedUnlock);
        bool ownershipTransferred = (postOwner == address(0));
        
        console.log("Owner changed: %s", ownerChanged ? "YES" : "NO");
        console.log("Unlock time changed: %s", unlockedTimeChanged ? "YES" : "NO");
        console.log("Correct unlock time set: %s", unlockTimeCorrect ? "YES" : "NO");
        console.log("Ownership transferred to: %s", postOwner);

        // Final vulnerability verdict
        if (ownerChanged && ownershipTransferred && unlockTimeCorrect) {
            console.log("Vulnerability Exists: Lock function permanently transfers ownership and sets unlock time to distant future");
        } else {
            console.log("Vulnerability not Exist: Contract state did not change as expected");
            if (!ownerChanged) console.log("- Owner address remained unchanged");
            if (!ownershipTransferred) console.log("- Ownership not transferred to zero address");
            if (!unlockTimeCorrect) console.log("- Unlock time calculation incorrect");
        }
    }
}