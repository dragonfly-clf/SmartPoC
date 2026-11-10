// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/PINUToken.sol";

// Mock contracts to satisfy PINUToken constructor requirements
contract MockPinkAntiBot {
    function setTokenOwner(address) public pure {
        // Empty function to satisfy interface
    }
}

contract MockRouter {
    function factory() external pure returns (address) {
        return address(0);
    }
}

contract PINUTokenStateTest is Test {
    PINUToken token;
    address user1 = address(0x1);
    address user2 = address(0x2);
    MockRouter mockRouter;
    
    function setUp() public {
        // Create mock contracts
        MockPinkAntiBot mockBot = new MockPinkAntiBot();
        mockRouter = new MockRouter();
        
        // Create token with mocks
        address[] memory emptyPairs;
        token = new PINUToken(
            address(mockBot),
            emptyPairs,
            address(0x3)  // Dummy reward token
        );
        
        // Manually set router to mock since real router not needed
        token.setLpAddress(address(mockRouter), true);
    }

    function test_lpAddressInconsistency() public {
        bool vulnerabilityDetected = false;
        
        // Test setting true twice
        console.log("--- BEFORE-Trigger: Set LP (true) ---");
        bool initialLpStatus = token.lpAddresses(user1);
        console.log("Initial lpAddresses[user1]:", initialLpStatus);
        
        console.log("--- Trigger: setLpAddress(user1, true) ---");
        token.setLpAddress(user1, true);
        
        console.log("--- AFTER-Trigger: Set LP (true) ---");
        bool afterFirstSet = token.lpAddresses(user1);
        console.log("lpAddresses[user1] after first true set:", afterFirstSet);

        // Pre-state for inconsistency test
        console.log("\n--- BEFORE-Trigger: Inconsistent Set (true again) ---");
        bool beforeTrigger = token.lpAddresses(user1);
        console.log("State before:", beforeTrigger);
        
        // Trigger inconsistent update
        console.log("--- Trigger: setLpAddress(user1, true) again ---");
        token.setLpAddress(user1, true);
        
        // Post-state check
        console.log("--- AFTER-Trigger: Inconsistent Set (true again) ---");
        bool afterTrigger = token.lpAddresses(user1);
        console.log("State after:", afterTrigger);
        
        // Differential validation
        if (beforeTrigger != afterTrigger) {
            console.log("VULNERABILITY: State changed for same-value set!");
            vulnerabilityDetected = true;
        } else {
            console.log("State consistent: No change detected");
        }

        // Reset for next test
        token.setLpAddress(user1, false);
        
        // Test setting false twice
        console.log("\n--- BEFORE-Trigger: Inconsistent Set (false again) ---");
        beforeTrigger = token.lpAddresses(user1);
        console.log("State before:", beforeTrigger);
        
        console.log("--- Trigger: setLpAddress(user1, false) again ---");
        token.setLpAddress(user1, false);
        
        console.log("--- AFTER-Trigger: Inconsistent Set (false again) ---");
        afterTrigger = token.lpAddresses(user1);
        console.log("State after:", afterTrigger);
        
        // Differential validation
        if (beforeTrigger != afterTrigger) {
            console.log("VULNERABILITY: State changed for same-value set!");
            vulnerabilityDetected = true;
        } else {
            console.log("State consistent: No change detected");
        }

        // Final verdict
        if (vulnerabilityDetected) {
            console.log("\nVulnerability Exists: State inconsistency in lpAddresses");
        } else {
            console.log("\nVulnerability not Exist: lpAddresses state updates consistent");
        }
    }

    function test_excludeFeeInconsistency() public {
        address[] memory users = new address[](2);
        users[0] = user1;
        users[1] = user2;
        bool vulnerabilityDetected = false;

        // Initial exclude setup
        token.setExcludeFee(users, true);

        // Pre-state for inconsistency test (exclude again)
        console.log("--- BEFORE-Trigger: Inconsistent Set (true again) ---");
        bool[2] memory beforeStatus;
        beforeStatus[0] = token.excludeFee(users[0]);
        beforeStatus[1] = token.excludeFee(users[1]);
        console.log("excludeFee[user1] before:", beforeStatus[0]);
        console.log("excludeFee[user2] before:", beforeStatus[1]);
        
        // Trigger inconsistent update
        console.log("--- Trigger: setExcludeFee(users, true) again ---");
        token.setExcludeFee(users, true);
        
        // Post-state check
        console.log("--- AFTER-Trigger: Inconsistent Set (true again) ---");
        bool[2] memory afterStatus;
        afterStatus[0] = token.excludeFee(users[0]);
        afterStatus[1] = token.excludeFee(users[1]);
        console.log("excludeFee[user1] after:", afterStatus[0]);
        console.log("excludeFee[user2] after:", afterStatus[1]);
        
        // Differential validation
        for (uint i = 0; i < users.length; i++) {
            if (beforeStatus[i] != afterStatus[i]) {
                console.log("VULNERABILITY: State changed for user%d!", i);
                vulnerabilityDetected = true;
            }
        }

        // Remove exclusions
        token.setExcludeFee(users, false);

        // Test setting false twice
        console.log("\n--- BEFORE-Trigger: Inconsistent Set (false again) ---");
        beforeStatus[0] = token.excludeFee(users[0]);
        beforeStatus[1] = token.excludeFee(users[1]);
        console.log("excludeFee[user1] before:", beforeStatus[0]);
        console.log("excludeFee[user2] before:", beforeStatus[1]);
        
        console.log("--- Trigger: setExcludeFee(users, false) again ---");
        token.setExcludeFee(users, false);
        
        console.log("--- AFTER-Trigger: Inconsistent Set (false again) ---");
        afterStatus[0] = token.excludeFee(users[0]);
        afterStatus[1] = token.excludeFee(users[1]);
        console.log("excludeFee[user1] after:", afterStatus[0]);
        console.log("excludeFee[user2] after:", afterStatus[1]);
        
        // Differential validation
        for (uint i = 0; i < users.length; i++) {
            if (beforeStatus[i] != afterStatus[i]) {
                console.log("VULNERABILITY: State changed for user%d!", i);
                vulnerabilityDetected = true;
            }
        }

        // Final verdict
        if (vulnerabilityDetected) {
            console.log("\nVulnerability Exists: State inconsistency in excludeFee");
        } else {
            console.log("\nVulnerability not Exist: excludeFee state updates consistent");
        }
    }
}