// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/GDG.sol";

contract GDGFeeManipulationTest is Test {
    GDG token;
    address owner = makeAddr("owner");
    string public BSC_RPC_URL = "https://bsc-dataseed.binance.org/";
    
    function setUp() public {
        // Create and select BSC fork using direct RPC URL
        uint256 bscFork = vm.createFork(BSC_RPC_URL);
        vm.selectFork(bscFork);

        // Deploy token contract as owner
        vm.startPrank(owner);
        token = new GDG();
        vm.stopPrank();
    }

    function testOwnerCanSetExcessiveTaxFee() public {
        uint256 excessiveFee = 26; // Above 25% limit
        
        console.log("--- BEFORE-Trigger TaxFee Query ---");
        // Query current tax fee value
        uint256 initialTaxFee = token._taxFee();
        console.log("Initial Tax Fee (%%):", initialTaxFee);
        
        console.log("--- Trigger SetTaxFeePercent ---");
        // Attempt to set tax fee above 25%
        vm.prank(owner);
        token.setTaxFeePercent(excessiveFee);
        
        console.log("--- AFTER-Trigger TaxFee Query ---");
        // Verify tax fee was updated to excessive value
        uint256 updatedTaxFee = token._taxFee();
        console.log("Updated Tax Fee (%%):", updatedTaxFee);
        console.log("Excessive Threshold: 25%% | Set Value: %s%%", excessiveFee);
        
        // Vulnerability verification logic
        if (updatedTaxFee == excessiveFee) {
            console.log("Vulnerability Exists: Validated tax fee set to %s%% (exceeding 25%%)", excessiveFee);
        } else {
            console.log("Vulnerability not Exist: Contract prevented tax fee change to excessive value");
        }
    }
}