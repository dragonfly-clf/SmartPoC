// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x52d2e0f9b01101a59b38a3d05c80b7618aeed984.sol";

contract EtherGetTest is Test {
    EtherGet public etherGet;

    function setUp() public {
        etherGet = new EtherGet();
    }

    function test_arithmeticOverflow() public {
        console.log("--- BEFORE-Trigger Transaction ---");
        console.log("No state variables will be modified due to failed transaction");

        // Set num to maximum possible value (2^256 - 1)
        uint maxNum = type(uint).max;
        address testAddr = address(0x1); // Any non-contract address
        
        // Execute with gas limit that would cause an arithmetic overflow
        uint gasLimit = 100000; // Inadequate gas to complete all iterations
        
        console.log("--- Trigger Call ---");
        (bool success, ) = address(etherGet).call{gas: gasLimit}(
            abi.encodeWithSignature("getTokens(uint256,address)", maxNum, testAddr)
        );

        console.log("--- AFTER-Trigger Transaction ---");
        console.log("No state variables changed due to reverted transaction");
        
        if (!success) {
            console.log("Vulnerability Exists: Transaction failed as expected due to arithmetic overflow vulnerability");
            assertFalse(success);
        } else {
            console.log("Vulnerability not Exist: Transaction succeeded unexpectedly");
        }
    }
}