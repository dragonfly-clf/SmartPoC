// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb0510d68f210b7db66e8c7c814f22680f2b8d1d6.sol";

contract PuppetHardcodedAddressTest is Test {
    Splitter public splitter;
    Puppet public puppet;
    
    address constant HARDCODED_TARGET = 0x509Cb8cB2F8ba04aE81eEC394175707Edd37e109;
    address constant HARDCODED_MASTER = 0x5C035Bb4Cb7dacbfeE076A5e61AA39a10da2E956;

    function setUp() public {
        // Deploy Splitter which creates Puppet instances
        splitter = new Splitter();
        
        // Get first puppet address from Splitter's puppets array
        // Explicitly convert to payable address for Puppet contract
        address payable puppetAddress = payable(splitter.puppets(0));
        puppet = Puppet(puppetAddress);
    }

    function testPuppetHasHardcodedAddresses() public {
        console.log("--- BEFORE-Trigger State Query ---");
        console.log("Querying Puppet contract addresses...");
        
        console.log("--- Trigger Verification ---");
        // Verify the hardcoded addresses in Puppet contract
        bool targetMatch = (puppet.target(0) == HARDCODED_TARGET);
        bool masterMatch = (puppet.master(0) == HARDCODED_MASTER);
        bool vulnerabilityExists = targetMatch && masterMatch;
        
        console.log("--- AFTER-Trigger State Query ---");
        console.log("Target address match:", targetMatch);
        console.log("Master address match:", masterMatch);
        
        // Final vulnerability verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Puppet contains immutable hardcoded addresses");
        } else {
            console.log("Vulnerability not Exist: Addresses are configurable or incorrect");
        }
    }
}