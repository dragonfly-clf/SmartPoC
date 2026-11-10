// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/THRToken.sol";

contract THRTokenTest is Test {
    THRToken thrToken;
    address public immutable DEPLOYER = 0x66a4b9a21B402B395254EA5C1c7d640644788888;
    uint256 constant MAX_ALLOWED_FEE = 25;
    
    function setUp() public {
        // Create a fork of Binance Smart Chain to handle external contract calls
        vm.createSelectFork("https://bsc-dataseed1.binance.org");
        // Deploy the token contract
        thrToken = new THRToken();
    }

    function testOwnerCanExceedFeeLimit() public {
        // Record initial tax fee
        uint256 exceededFee = MAX_ALLOWED_FEE + 1;
        console.log("--- BEFORE-Trigger Tax Fee ---");
        uint256 initialTaxFee = thrToken._taxFee();
        console.log("Initial Tax Fee:", initialTaxFee);
        console.log("Allowed Maximum Fee:", MAX_ALLOWED_FEE);
        
        console.log("--- Trigger setTaxFeePercent with exceeded fee (26%) ---");
        // Impersonate the contract owner and set fee beyond limit
        vm.startPrank(DEPLOYER);
        thrToken.setTaxFeePercent(exceededFee);
        vm.stopPrank();
        
        // Record new tax fee after modification
        console.log("--- AFTER-Trigger Tax Fee ---");
        uint256 newTaxFee = thrToken._taxFee();
        console.log("New Tax Fee:", newTaxFee);
        console.log("Attempted Fee Setting:", exceededFee);
        
        // Determine if vulnerability exists based on state change
        bool feeExceededAllowed = (newTaxFee > MAX_ALLOWED_FEE);
        if(feeExceededAllowed) {
            console.log("Vulnerability Exists: Owner successfully set tax fee beyond allowed limit");
            assertTrue(feeExceededAllowed, "Vulnerability confirmed: tax fee exceeds 25% limit");
        } else {
            console.log("Vulnerability not Exist: Contract prevents owner from exceeding fee limit");
            assertFalse(feeExceededAllowed, "Security feature works: tax fee remains within limits");
        }
    }
}