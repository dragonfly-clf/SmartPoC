// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/FutuballToken.sol";

contract MockFactory {
    function createPair(address, address) external pure returns (address) {
        return address(0xA);
    }
}

contract AuditReportTest is Test {
    FutuballToken token;
    address owner = address(0x1);
    address constant PANCAKE_ROUTER = address(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address victim = address(0xAAA);

    function setUp() public {
        vm.startPrank(owner);
        
        // Deploy mock factory
        MockFactory mockFactory = new MockFactory();
        
        // Setup mock router responses using function signatures
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("factory()"),
            abi.encode(address(mockFactory))
        );
        vm.mockCall(
            PANCAKE_ROUTER,
            abi.encodeWithSignature("WETH()"),
            abi.encode(address(0xB))
        );

        // Deploy token contract
        token = new FutuballToken();
        
        // Configure initial fee settings
        token.applyFee(true);
        token.excludeFromFee(owner);
        vm.stopPrank();
    }

    function test_taxManipulation() public {
        // === PART 1: Tax Rate Manipulation ===
        console.log("--- BEFORE-TRIGGER: Tax Rate Verification ---");
        uint256 buyTaxBefore = token.buyTaxFee();
        uint256 sellTaxBefore = token.sellTaxFee();
        console.log("Pre-setTax buyTaxFee:", buyTaxBefore);
        console.log("Pre-setTax sellTaxFee:", sellTaxBefore);

        console.log("--- TRIGGER: setTax(100,100) ---");
        vm.prank(owner);
        token.setTax(100, 100);  // Attempt to set both taxes to 100%

        console.log("--- AFTER-TRIGGER: Tax Rate Verification ---");
        uint256 buyTaxAfter = token.buyTaxFee();
        uint256 sellTaxAfter = token.sellTaxFee();
        console.log("Post-setTax buyTaxFee:", buyTaxAfter);
        console.log("Post-setTax sellTaxFee:", sellTaxAfter);

        bool taxManipulated = (buyTaxAfter == 100) && (sellTaxAfter == 100);
        console.log("Tax manipulation result:", taxManipulated ? "SUCCESSFUL - Vulnerability" : "RESTRICTED - Secure");

        // === PART 2: Tax Address Manipulation ===
        console.log("--- BEFORE-TRIGGER: Tax Address Verification ---");
        address taxAddrBefore = token.taxAddress();
        console.log("Pre-setTaxAddress taxAddress:", taxAddrBefore);

        console.log("--- TRIGGER: setTaxAddress(newAddress) ---");
        address newTaxAddr = address(0x999);
        vm.prank(owner);
        token.setTaxAddress(newTaxAddr);

        console.log("--- AFTER-TRIGGER: Tax Address Verification ---");
        address taxAddrAfter = token.taxAddress();
        console.log("Post-setTaxAddress taxAddress:", taxAddrAfter);

        bool taxAddrChanged = (taxAddrAfter == newTaxAddr);
        console.log("Tax address change result:", taxAddrChanged ? "SUCCESSFUL - Vulnerability" : "RESTRICTED - Secure");

        // === PART 3: Fee Exemption Removal ===
        // First exclude victim to prepare test state
        vm.prank(owner);
        token.excludeFromFee(victim);

        console.log("--- BEFORE-TRIGGER: Victim Exclusion Status ---");
        bool isExcludedBefore = token.isExcludedFromFee(victim);
        console.log("Pre-includeInFee exclusion status:", isExcludedBefore);

        console.log("--- TRIGGER: includeInFee(victim) ---");
        vm.prank(owner);
        token.includeInFee(victim);

        console.log("--- AFTER-TRIGGER: Victim Exclusion Status ---");
        bool isExcludedAfter = token.isExcludedFromFee(victim);
        console.log("Post-includeInFee exclusion status:", isExcludedAfter);

        bool exemptionRemoved = !isExcludedAfter;
        console.log("Exemption removal result:", exemptionRemoved ? "SUCCESSFUL - Vulnerability" : "RESTRICTED - Secure");

        // === FINAL VULNERABILITY ASSESSMENT ===
        if (taxManipulated || taxAddrChanged || exemptionRemoved) {
            console.log("Vulnerability Exists: Owner can manipulate critical token parameters arbitrarily");
        } else {
            console.log("Vulnerability not Exist: All tested state changes were restricted");
        }
    }
}