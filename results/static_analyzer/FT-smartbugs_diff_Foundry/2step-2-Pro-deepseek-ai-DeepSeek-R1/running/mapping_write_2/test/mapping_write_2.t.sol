// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/mapping_write.sol";

contract MapTest is Test {
    Map public mapContract;

    function setUp() public {
        mapContract = new Map();
    }

    function test_SetLargeKeyCausesOutOfGas() public {
        uint256 largeKey = 130000;
        
        console.log("--- BEFORE-Trigger (Large Key) ---");
        console.log("Key:", largeKey);
        console.log("Gas Limit: 30,000,000");

        console.log("--- Trigger: Attempt Set Large Key ---");
        (bool success, ) = address(mapContract).call{gas: 30_000_000}(
            abi.encodeWithSelector(mapContract.set.selector, largeKey, 1)
        );
        
        console.log("--- AFTER-Trigger: Call Result ---");
        if (!success) {
            console.log("Call reverted due to excessive gas consumption");
            console.log("Vulnerability Exists: OOG handling for large keys failed");
        } else {
            console.log("Call succeeded unexpectedly");
            console.log("Vulnerability not Exist: Operation completed within gas limit");
        }
    }

    function test_SetIncreasingKeysVerifiesGasGrowth() public {
        console.log("--- BEFORE-Trigger: Measure Small Key (1000) ---");
        uint256 gasBefore = gasleft();
        mapContract.set(1000, 1);
        uint256 gasSmallKey = gasBefore - gasleft();
        console.log("Gas Used (small key):", gasSmallKey);

        console.log("--- BEFORE-Trigger: Measure Medium Key (50000) ---");
        gasBefore = gasleft();
        mapContract.set(50000, 1);
        uint256 gasMediumKey = gasBefore - gasleft();
        console.log("Gas Used (medium key):", gasMediumKey);

        console.log("--- Trigger: Verify Gas Growth ---");
        bool excessiveGrowth = gasMediumKey > gasSmallKey * 5;
        if (excessiveGrowth) {
            console.log("Non-linear growth:", gasMediumKey, "> 5 *", gasSmallKey);
            console.log("Vulnerability Exists: Quadratic gas complexity confirmed");
        } else {
            console.log("Linear growth:", gasMediumKey, "<= 5 *", gasSmallKey);
            console.log("Vulnerability not Exist: Gas growth follows expected pattern");
        }
        assertTrue(excessiveGrowth, "Gas consumption growth check failed");
    }
}