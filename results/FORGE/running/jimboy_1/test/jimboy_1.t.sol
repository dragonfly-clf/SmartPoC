// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/JIMBOY.sol";

contract JIMBOYTest is Test {
    JIMBOY token;
    address owner = address(this);

    function setUp() public {
        token = new JIMBOY();
        // Token owner is already set to test contract address
    }

    function test_FeeExceedsLimitVulnerability() public {
        console2.log("--- BEFORE-Trigger ---");
        console2.log("Attempting to set fee to 26% (13+13) - should revert if fixed");

        console2.log("--- Trigger Action ---");
        bool success;
        try token.setFee(13, 13, 13, 13) {
            success = true; // Fee set successfully -> vulnerability exists
        } catch {
            success = false; // Reverted -> security mechanism works
        }

        console2.log("--- AFTER-Trigger ---");
        console2.log("Transaction result:", success ? "SUCCESS" : "REVERT");
        
        if (success) {
            console2.log("Verdict: Fees set above 25% without revert -> Vulnerability exists");
            console2.log("Vulnerability Exists: Fee parameters can exceed 25% limit");
        } else {
            console2.log("Verdict: Transaction reverted -> Security mechanism works");
            console2.log("Vulnerability not Exist: Fee restrictions enforced");
        }
    }
}