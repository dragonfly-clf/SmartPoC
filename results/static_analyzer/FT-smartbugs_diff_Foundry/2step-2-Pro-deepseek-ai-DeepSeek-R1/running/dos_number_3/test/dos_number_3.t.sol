// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/dos_number.sol";

contract DosNumberTest is Test {
    DosNumber dosNumber;

    function setUp() public {
        dosNumber = new DosNumber();
    }

    function test_insertLargeValueRevertsDueToGasLimit() public {
        uint256 blockGasLimit = 30_000_000; // Ethereum mainnet block gas limit
        uint256 largeInsertCount = 1_000_000; // Guaranteed to exceed gas limit

        console.log("--- BEFORE-Trigger: Pre-Transaction ---");
        console.log("Preparing gas-limited transaction (blockGasLimit: %s)", blockGasLimit);

        console.log("--- Trigger Call ---");
        address target = address(dosNumber);
        (bool success, ) = target.call{gas: blockGasLimit}(
            abi.encodeWithSelector(
                dosNumber.insertNnumbers.selector, 
                0, 
                largeInsertCount
            )
        );

        console.log("--- AFTER-Trigger: Post-Transaction ---");
        console.log("Transaction status: %s", success ? "SUCCESS" : "REVERTED");
        
        // Vulnerability verdict logic
        if (!success) {
            console.log("Vulnerability Exists: Transaction reverted due to gas exhaustion");
        } else {
            console.log("Vulnerability not Exist: Transaction succeeded within gas limits");
        }

        // Final verification
        assertFalse(success, "Transaction should fail due to gas limit exceedance");
    }
}