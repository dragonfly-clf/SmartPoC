// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/ACRUX.sol";

contract ContractCaller {
    function makeCall(
        address target,
        bytes memory data
    ) public returns (bytes memory) {
        return Address.functionCall(target, data);
    }
}

contract DummyTarget {
    function failFunction() public pure {
        revert();
    }
    
    function failWithReason() public pure {
        revert("CustomRevertReason");
    }
    
    function successFunction() public pure returns (uint) {
        return 42;
    }
}

contract ACRUXLowLevelCallTest is Test {
    ContractCaller caller;
    DummyTarget dummyTarget;
    
    function setUp() public {
        caller = new ContractCaller();
        dummyTarget = new DummyTarget();
    }
    
    // Test case for failure without custom reason
    function testLowLevelCallFailureNoReason() public {
        bytes memory data = abi.encodeWithSignature("failFunction()");
        try caller.makeCall(address(dummyTarget), data) {
            console.log("Vulnerability Exists: Low-level call failed with unexpected success");
        } catch Error(string memory reason) {
            if (keccak256(bytes(reason)) == keccak256(bytes("Address: low-level call failed"))) {
                console.log("Vulnerability not Exist: Low-level call failed as expected");
            } else {
                console.log("Vulnerability Exists: Low-level call failed with incorrect reason");
            }
        } catch (bytes memory) {
            console.log("Vulnerability Exists: Low-level call failed with non-string error");
        }
    }
    
    // Test case for failure with custom reason
    function testLowLevelCallFailureWithReason() public {
        bytes memory data = abi.encodeWithSignature("failWithReason()");
        try caller.makeCall(address(dummyTarget), data) {
            console.log("Vulnerability Exists: Low-level call failed with unexpected success");
        } catch Error(string memory reason) {
            if (keccak256(bytes(reason)) == keccak256(bytes("CustomRevertReason"))) {
                console.log("Vulnerability not Exist: Custom revert reason propagated correctly");
            } else {
                console.log("Vulnerability Exists: Incorrect revert reason received");
            }
        } catch (bytes memory) {
            console.log("Vulnerability Exists: Revert without expected string reason");
        }
    }
    
    function testLowLevelCallSuccess() public {
        bytes memory data = abi.encodeWithSignature("successFunction()");
        try caller.makeCall(address(dummyTarget), data) returns (bytes memory result) {
            uint decoded = abi.decode(result, (uint256));
            if (decoded == 42) {
                console.log("Vulnerability not Exist: Successful call returned correct value");
            } else {
                console.log("Vulnerability Exists: Return value mismatch");
            }
        } catch Error(string memory reason) {
            console.log("Vulnerability Exists: Unexpected revert - ", reason);
        } catch (bytes memory) {
            console.log("Vulnerability Exists: Unexpected low-level failure");
        }
    }
}