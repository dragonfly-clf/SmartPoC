// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LINKDAO_Token.sol";

contract MintTest is Test {
    LINKDAO_Token token;
    address owner = address(this);
    uint256 initialSupply;
    uint256 maxSupply;

    function setUp() public {
        token = new LINKDAO_Token();
        initialSupply = token.totalSupply();
        maxSupply = token.maxSupply();
    }

    function test_MintExceedsMaxSupply() public {
        uint256 excessAmount = maxSupply - initialSupply + 1;
        
        console.log("--- BEFORE-Trigger Mint ---");
        uint256 totalSupplyBefore = token.totalSupply();
        console.log("Total Supply Before: ", totalSupplyBefore);
        
        console.log("--- Trigger Mint (excess amount: ", excessAmount, ") ---");
        bool mintSuccess = token.mint(excessAmount);
        console.log("Mint result: ", mintSuccess ? "success" : "fail");
        
        console.log("--- AFTER-Trigger Mint ---");
        uint256 totalSupplyAfter = token.totalSupply();
        console.log("Total Supply After: ", totalSupplyAfter);
        
        bool supplyChanged = totalSupplyAfter != totalSupplyBefore;
        console.log("State change: ", supplyChanged ? "SUCCESS (changed)" : "FAIL (unchanged)");
        console.log("Final verdict calculation: mintSuccess=", mintSuccess, ", supplyChanged=", supplyChanged);
        
        // Final vulnerability determination
        if (mintSuccess && !supplyChanged) {
            console.log("Vulnerability Exists: mint returns true despite failing to mint tokens (supply unchanged)");
        } else {
            console.log("Vulnerability not Exist: expected behavior (either mint failed or supply increased)");
        }
    }
}