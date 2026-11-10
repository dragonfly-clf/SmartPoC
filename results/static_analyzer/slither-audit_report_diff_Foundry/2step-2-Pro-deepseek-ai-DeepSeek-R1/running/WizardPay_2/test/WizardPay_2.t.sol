// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/WizardPay.sol";

contract UninitializedStateTest is Test {
    WizardPay public wizardPay;
    address owner = address(0xABCD);
    address randomUser = address(0x1234);

    function setUp() public {
        vm.prank(owner);
        wizardPay = new WizardPay();
    }

    function testNoAddressesExcluded() public {
        console.log("--- BEFORE-Trigger State ---");
        bool ownerExcludedBefore = wizardPay.isExcluded(owner);
        bool contractExcludedBefore = wizardPay.isExcluded(address(wizardPay));
        bool randomExcludedBefore = wizardPay.isExcluded(randomUser);
        console.log("Owner excluded status (BEFORE):", ownerExcludedBefore);
        console.log("Contract excluded status (BEFORE):", contractExcludedBefore);
        console.log("Random user excluded status (BEFORE):", randomExcludedBefore);

        // Vulnerability only requires static state verification
        console.log("--- Trigger Action ---");
        console.log("No action required - checking static state");

        console.log("--- AFTER-Trigger State ---");
        bool ownerExcludedAfter = wizardPay.isExcluded(owner);
        bool contractExcludedAfter = wizardPay.isExcluded(address(wizardPay));
        bool randomExcludedAfter = wizardPay.isExcluded(randomUser);
        console.log("Owner excluded status (AFTER):", ownerExcludedAfter);
        console.log("Contract excluded status (AFTER):", contractExcludedAfter);
        console.log("Random user excluded status (AFTER):", randomExcludedAfter);
        
        bool anyAddressExcluded = ownerExcludedAfter || 
                                 contractExcludedAfter || 
                                 randomExcludedAfter;
        
        // Final vulnerability verdict - correctly inverted condition
        if (anyAddressExcluded) {
            console.log("Vulnerability Exists: One or more addresses are incorrectly excluded");
        } else {
            console.log("Vulnerability not Exist: This is expected behavior - no addresses should be excluded");
        }
    }
}