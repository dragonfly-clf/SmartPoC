// SPDX-License-Identifier: MIT
pragma solidity 0.8.3;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/WizardPay.sol";

contract WizardPayExcludedTest is Test {
    WizardPay token;
    address deployer = address(0x1);
    address excluded1 = address(0x2);

    function setUp() public {
        vm.prank(deployer);
        token = new WizardPay();
    }

    // Test to verify critical excluded arrays remain uninitialized
    function test_initialExclusions() public {
        // Log initial state
        console.log("--- BEFORE-Trigger ---");
        console.log("Deployer excluded:", token.isExcluded(deployer));
        console.log("Contract excluded:", token.isExcluded(address(token)));
        console.log("External excluded:", token.isExcluded(excluded1));
        
        console.log("--- Trigger ---");
        console.log("No action (static vulnerability check)");
        
        // Post-trigger logging (state remains unchanged)
        console.log("--- AFTER-Trigger ---");
        console.log("Deployer excluded:", token.isExcluded(deployer));
        console.log("Contract excluded:", token.isExcluded(address(token)));
        console.log("External excluded:", token.isExcluded(excluded1));
        
        // Vulnerability detection
        if (token.isExcluded(deployer) || 
            token.isExcluded(address(token)) || 
            token.isExcluded(excluded1)) 
        {
            console.log("Vulnerability Exists: critical addresses excluded in initial state");
        } else {
            console.log("Vulnerability not Exist: initial state exclusion is correct");
        }
    }
}