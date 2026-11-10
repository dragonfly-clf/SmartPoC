// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/LFGdoge.sol";

contract LFGdogeTaxManipulationTest is Test {
    LFGdoge token;
    address owner = address(0x1);
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;

    function setUp() public {
        // Mock router and factory calls to prevent deployment reverts
        vm.mockCall(ROUTER, abi.encodeWithSignature("factory()"), abi.encode(address(0x111)));
        vm.mockCall(ROUTER, abi.encodeWithSignature("WETH()"), abi.encode(address(0x222)));
        vm.mockCall(address(0x111), abi.encodeWithSignature("createPair(address,address)"), abi.encode(address(0x333)));

        // Deploy token as owner
        vm.startPrank(owner);
        token = new LFGdoge();
        vm.stopPrank();
    }

    function test_tax_can_be_set_above_intended_limit() public {
        console.log("--- BEFORE-Trigger Taxes ---");
        uint256 initialMarketingFee = token._marketingFee();
        uint256 initialTotalTax = token._totalTax();
        console.log("Initial marketingFee: %s%", initialMarketingFee);
        console.log("Initial totalTax: %s%", initialTotalTax);

        console.log("--- Trigger: setTaxes(26) ---");
        uint256 highTaxFee = 26; // Intended limit violation
        vm.prank(owner);
        token.setTaxes(highTaxFee);
        
        console.log("--- AFTER-Trigger Taxes ---");
        uint256 newMarketingFee = token._marketingFee();
        uint256 newTotalTax = token._totalTax();
        console.log("New marketingFee: %s%", newMarketingFee);
        console.log("New totalTax: %s%", newTotalTax);
        
        bool feeChanged = (newMarketingFee == 26 && newTotalTax == 26) && 
                         (newMarketingFee != initialMarketingFee || newTotalTax != initialTotalTax);
        bool aboveLimit = (newMarketingFee > 25);
        
        if (feeChanged && aboveLimit) {
            console.log("STATE CHANGE VERIFIED: Both taxes increased to 26% (above 25% limit)");
            console.log("Vulnerability Exists: Tax can be set above intended 25%% limit");
        } else {
            console.log("STATE CHANGE VERIFICATION FAILED: Taxes not set to 26%% or below limit");
            console.log("Vulnerability not Exist: Constraint prevents taxes exceeding 25%%");
        }
    }
}