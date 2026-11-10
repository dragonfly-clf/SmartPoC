// SPDX-License-Identifier: MIT
pragma solidity 0.8.13;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CarGaiaToken.sol";

contract CarGaiaTokenTest is Test {
    CarGaiaToken token;
    
    // Fixed distribution addresses
    address constant SALE = address(0xA11c3);
    address constant COMMUNITY = address(0xB0b);
    address constant ADVISOR = address(0xC4FE);
    address constant ECOSYSTEM = address(0xF00d);
    address constant FOUNDATION = address(0xFee1);
    address constant team = address(0x12345); // Team address
    
    function setUp() public {
        // Set initial timestamp to 1 (to avoid 0 timestamp arithmetic issues)
        vm.warp(1);
        
        // Deploy token with a large but safe initial supply (1 billion tokens with 18 decimals)
        uint256 initialSupply = 1_000_000_000e18;
        token = new CarGaiaToken(
            initialSupply,
            "CarGaia",
            "CG",
            18,
            SALE,
            COMMUNITY,
            ADVISOR,
            ECOSYSTEM,
            FOUNDATION,
            team
        );
    }

    function test_UnlockOfOverflow() public {
        console.log("--- BEFORE-Trigger State ---");
        console.log("No state changes required for this test");

        console.log("--- Trigger Operation: Call unlockOf at max timestamp ---");
        // Advance to maximum possible timestamp to trigger overflow in vesting calculation
        vm.warp(type(uint256).max);
        (bool success, ) = address(token).staticcall(
            abi.encodeWithSelector(token.unlockOf.selector, team)
        );

        console.log("--- AFTER-Trigger Result ---");
        console.log("Function reverted:", !success ? "YES" : "NO");

        // Final vulnerability verdict
        if (!success) {
            console.log("Vulnerability Exists: unlockOf function reverts due to overflow at max timestamp");
        } else {
            console.log("Vulnerability not Exist: unlockOf function executes normally at max timestamp");
        }
    }
}