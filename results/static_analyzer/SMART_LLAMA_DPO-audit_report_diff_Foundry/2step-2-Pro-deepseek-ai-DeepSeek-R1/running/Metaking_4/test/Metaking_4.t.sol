// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Metaking.sol";

contract MockUniswapV2Factory {
    function createPair(address, address) external pure returns (address) {
        return address(0x111);
    }
}

contract MockUniswapV2Router {
    address public factory;
    constructor() {
        // This constructor doesn't run during vm.etch, we'll set factory via storage later
    }
    function WETH() external pure returns (address) {
        return address(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
    }
}

contract MetakingLockTest is Test {
    Metaking public token;
    address owner = address(0x123);
    address user = address(0x456);
    uint256 constant INITIAL_TIME = 1000;
    uint256 constant LOCK_DURATION = 7 days;

    address constant ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Set initial timestamp
        vm.warp(INITIAL_TIME);
        
        // Setup mock Uniswap contracts
        MockUniswapV2Factory mockFactory = new MockUniswapV2Factory();
        
        // Get mock router runtime code
        bytes memory routerRuntimeCode = type(MockUniswapV2Router).runtimeCode;
        
        // Deploy mock router to hardcoded address
        vm.etch(ROUTER_ADDRESS, routerRuntimeCode);
        
        // Set factory address in storage slot 0 (for public variable)
        vm.store(
            ROUTER_ADDRESS,
            bytes32(uint256(0)),
            bytes32(uint256(uint160(address(mockFactory))))
        );

        // Deploy Metaking contract
        vm.startPrank(owner);
        token = new Metaking();
        vm.stopPrank();
    }

    function testRepeatedLockVulnerability() public {
        // Before first lock: Record initial state
        console.log("--- BEFORE FIRST LOCK ---");
        address ownerBeforeLock = token.owner();
        uint256 unlockTimeBeforeLock = token.geUnlockTime();
        console.log("Owner: %s", ownerBeforeLock);
        console.log("Unlock Time: %s", unlockTimeBeforeLock);

        console.log("--- TRIGGER: FIRST LOCK ---");
        // Lock contract for 7 days
        vm.startPrank(owner);
        token.lock(LOCK_DURATION);
        vm.stopPrank();

        // After first lock: Verify state changes
        console.log("--- AFTER FIRST LOCK ---");
        address ownerAfterLock = token.owner();
        uint256 unlockTimeAfterLock = token.geUnlockTime();
        console.log("Owner: %s -> %s", ownerBeforeLock, ownerAfterLock);
        console.log("Unlock Time: %s -> %s", unlockTimeBeforeLock, unlockTimeAfterLock);
        bool lockedStateVerified = ownerAfterLock == address(0) && unlockTimeAfterLock == INITIAL_TIME + LOCK_DURATION;
        console.log(lockedStateVerified ? "Lock state valid" : "Lock state invalid");

        // Before unlock: Save pre-unlock state
        console.log("--- BEFORE UNLOCK ---");
        address ownerBeforeUnlock = token.owner();
        uint256 unlockTimeBeforeUnlock = token.geUnlockTime();
        console.log("Owner: %s", ownerBeforeUnlock);
        console.log("Unlock Time: %s", unlockTimeBeforeUnlock);
        
        console.log("--- TRIGGER: UNLOCK ---");
        // Fast-forward past lock period
        vm.warp(INITIAL_TIME + LOCK_DURATION + 1);
        // Unlock contract
        vm.prank(owner);
        token.unlock();

        // After unlock: Verify ownership restored
        console.log("--- AFTER UNLOCK ---");
        address ownerAfterUnlock = token.owner();
        uint256 unlockTimeAfterUnlock = token.geUnlockTime();
        console.log("Owner: %s -> %s", ownerBeforeUnlock, ownerAfterUnlock);
        console.log("Unlock Time: %s -> %s", unlockTimeBeforeUnlock, unlockTimeAfterUnlock);
        bool unlockStateVerified = ownerAfterUnlock == owner;
        console.log(unlockStateVerified ? "Unlock state valid" : "Unlock state invalid");

        // Before second lock: Save state
        console.log("--- BEFORE SECOND LOCK ---");
        address ownerBeforeSecondLock = token.owner();
        uint256 unlockTimeBeforeSecondLock = token.geUnlockTime();
        console.log("Owner: %s", ownerBeforeSecondLock);
        console.log("Unlock Time: %s", unlockTimeBeforeSecondLock);
        
        console.log("--- TRIGGER: SECOND LOCK ---");
        // Immediately re-lock for another period
        vm.startPrank(owner);
        token.lock(LOCK_DURATION);
        vm.stopPrank();

        // After second lock: Final state verification
        console.log("--- AFTER SECOND LOCK ---");
        address finalOwner = token.owner();
        uint256 finalUnlockTime = token.geUnlockTime();
        console.log("Owner: %s -> %s", ownerBeforeSecondLock, finalOwner);
        console.log("Unlock Time: %s -> %s", unlockTimeBeforeSecondLock, finalUnlockTime);

        // Vulnerability confirmation check
        bool vulnerabilityExists = finalOwner == address(0) && 
                                  finalUnlockTime == INITIAL_TIME + LOCK_DURATION + 1 + LOCK_DURATION;
        
        // Final verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Contract was successfully re-locked immediately after unlock");
        } else {
            console.log("Vulnerability not Exist: Contract failed to achieve vulnerable state after locking");
        }
    }
}