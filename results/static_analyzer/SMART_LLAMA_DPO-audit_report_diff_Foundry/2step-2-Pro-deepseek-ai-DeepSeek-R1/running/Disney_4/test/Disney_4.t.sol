// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Disney.sol";

contract DisneyInitializationTest is Test {
    Disney public disney;
    
    function setUp() public {
        // Deploy implementation contract
        disney = new Disney();
    }

    function test_initialize_revertsWhenCalledDirectly() public {
        console2.log("--- BEFORE-Trigger InitializeCall ---");
        // No state variables to record (implementation contract)
        console2.log("Status: Implementation contract deployed");
        
        console2.log("--- Trigger InitializeCall ---");
        // Attempt to initialize implementation contract directly
        (bool success, ) = address(disney).call(abi.encodeWithSelector(Disney.initialize.selector));
        
        console2.log("--- AFTER-Trigger InitializeCall ---");
        if (!success) {
            console2.log("Result: initialize() reverted as expected");
            console2.log("Vulnerability not Exist: Implementation contract initialization properly restricted");
        } else {
            console2.log("Result: initialize() executed successfully");
            console2.log("Vulnerability Exists: Implementation contract can be initialized");
        }
    }
}