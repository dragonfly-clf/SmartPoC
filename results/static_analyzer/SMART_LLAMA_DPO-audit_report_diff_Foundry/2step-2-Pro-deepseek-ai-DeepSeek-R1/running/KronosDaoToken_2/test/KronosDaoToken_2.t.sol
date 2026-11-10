pragma solidity 0.7.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/KronosDaoToken.sol";

contract Bytes4SetTestWrapper {
    using EnumerableSet for EnumerableSet.Bytes4Set;
    EnumerableSet.Bytes4Set internal set;

    function add(bytes4 value) external returns (bool) {
        return set.add(value);
    }

    function contains(bytes4 value) external view returns (bool) {
        return set.contains(value);
    }

    function length() external view returns (uint256) {
        return set.length();
    }

    function get(uint256 index) external view returns (bytes4) {
        return set.at(index);
    }
}

contract Audit_SetUniquenessTest is Test {
    Bytes4SetTestWrapper setWrapper;

    function setUp() public {
        setWrapper = new Bytes4SetTestWrapper();
    }
    
    // Helper function to convert uint to string
    function toStr(uint256 value) internal pure returns (string memory) {
        if (value == 0) return "0";
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + value % 10));
            value /= 10;
        }
        return string(buffer);
    }

    // Test that duplicates cannot be added to Bytes4Set
    function test_SetPreventsDuplicates() public {
        bytes4 value = 0x12345678;

        // First addition should succeed
        bool firstAdd = setWrapper.add(value);
        assertTrue(firstAdd, "First add should succeed");
        assertEq(setWrapper.length(), 1, "Set length should be 1 after first add");
        assertTrue(setWrapper.contains(value), "Set should contain value after first add");

        emit log("--- BEFORE-Trigger Duplicate Add ---");
        uint256 beforeLength = setWrapper.length();
        bool beforeContains = setWrapper.contains(value);
        emit log_named_uint("setWrapper.length()", beforeLength);
        emit log_named_string("setWrapper.contains(value)", beforeContains ? "true" : "false");

        emit log("--- Trigger Duplicate Add ---");
        bool secondAdd = setWrapper.add(value);
        emit log_named_string("Attempt to add duplicate returned", secondAdd ? "true" : "false");

        emit log("--- AFTER-Trigger Duplicate Add ---");
        uint256 afterLength = setWrapper.length();
        bool afterContains = setWrapper.contains(value);
        emit log_named_uint("setWrapper.length()", afterLength);
        emit log_named_string("setWrapper.contains(value)", afterContains ? "true" : "false");

        // Vulnerability exists if:
        // - Duplicate add succeeded (secondAdd = true), OR
        // - Set length increased after duplicate add
        bool isVulnerable = secondAdd || (afterLength != beforeLength);
        
        // Final vulnerability verdict
        if (isVulnerable) {
            emit log("Vulnerability Exists: Set allowed adding duplicate element");
        } else {
            emit log("Vulnerability not Exist: Set correctly prevents duplicates");
        }

        // Original assertions remain
        assertFalse(secondAdd, "Duplicate add should fail");
        assertEq(setWrapper.length(), 1, "Set length should remain 1 after duplicate add attempt");
    }

    // Test that set maintains uniqueness with multiple elements
    function test_SetMaintainsUniqueness() public {
        bytes4 value = 0xabcdef12;
        
        // Add unique values
        setWrapper.add(0x11111111);
        setWrapper.add(value);
        setWrapper.add(0x22222222);
        
        emit log("--- BEFORE-Trigger Duplicate Add ---");
        uint256 beforeLength = setWrapper.length();
        bool beforeContains = setWrapper.contains(value);
        emit log_named_uint("setWrapper.length()", beforeLength);
        emit log_named_string("setWrapper.contains(value)", beforeContains ? "true" : "false");

        emit log("--- Trigger Duplicate Add ---");
        bool duplicateAdd = setWrapper.add(value);
        emit log_named_string("Attempt to add duplicate returned", duplicateAdd ? "true" : "false");
        
        emit log("--- AFTER-Trigger Duplicate Add ---");
        uint256 afterLength = setWrapper.length();
        bool afterContains = setWrapper.contains(value);
        emit log_named_uint("setWrapper.length()", afterLength);
        emit log_named_string("setWrapper.contains(value)", afterContains ? "true" : "false");

        // Vulnerability exists if duplicate added or length increased
        bool isVulnerable = duplicateAdd || (afterLength != beforeLength);
        
        // Final vulnerability verdict
        if (isVulnerable) {
            emit log("Vulnerability Exists: Set allowed duplicate in multi-element set");
        } else {
            emit log("Vulnerability not Exist: Set correctly prevents duplicates");
        }

        // Original assertions remain
        assertFalse(duplicateAdd, "Duplicate add should fail");
        assertEq(setWrapper.length(), 3, "Length should remain 3 after duplicate add attempt");
    }
}