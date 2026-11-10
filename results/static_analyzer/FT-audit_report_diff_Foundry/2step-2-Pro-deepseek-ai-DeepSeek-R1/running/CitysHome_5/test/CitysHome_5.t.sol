// SPDX-License-Identifier: MIT
pragma solidity 0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/CitysHome.sol";

contract CitysHomeMetadataTest is Test {
    CitysHome token;
    
    function setUp() public {
        token = new CitysHome();
    }

    function test_MetadataExternalCalls() public {
        console2.log("--- BEFORE Metadata Query ---");
        console2.log("No state changes expected - metadata is immutable");
        
        console2.log("--- Trigger: Query Metadata Functions ---");
        string memory name = token.name();
        string memory symbol = token.symbol();
        uint8 decimals = token.decimals();

        console2.log("--- AFTER Metadata Query ---");
        console2.log("Token Name:", name);
        console2.log("Token Symbol:", symbol);
        console2.log("Token Decimals:", decimals);

        console2.log("--- Comparison ---");
        bool nameMatches = keccak256(abi.encodePacked(name)) == keccak256(abi.encodePacked("CitysHome"));
        bool symbolMatches = keccak256(abi.encodePacked(symbol)) == keccak256(abi.encodePacked("CHC"));
        bool decimalsMatch = uint256(decimals) == 18;
        bool allMatch = nameMatches && symbolMatches && decimalsMatch;

        if (!nameMatches) console2.log("Name mismatch: expected 'CitysHome'");
        if (!symbolMatches) console2.log("Symbol mismatch: expected 'CHC'");
        if (!decimalsMatch) console2.log("Decimals mismatch: expected 18");

        console2.log("Metadata validation:", allMatch ? "PASS" : "FAIL");

        console2.log(allMatch 
            ? "Vulnerability not Exist: Metadata matches expected values" 
            : "Vulnerability Exists: Metadata fields mismatch expected values");
    }
}