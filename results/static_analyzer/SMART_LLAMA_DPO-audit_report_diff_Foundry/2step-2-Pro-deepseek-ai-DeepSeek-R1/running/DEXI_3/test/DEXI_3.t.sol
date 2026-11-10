// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/DEXI.sol";

contract DEXIAuditTest is Test {
    DEXI public token;
    address public owner = address(1);

    function setUp() public {
        vm.startPrank(owner);
        token = new DEXI();
        vm.stopPrank();
    }

    function test_setExcludeEnabled_missing_event() public {
        vm.startPrank(owner);
        vm.recordLogs();
        token.setExcludeEnabled(true);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        bytes32 expectedEventSig = keccak256("ExcludeEnabledUpdated(bool)");
        bool eventFound = false;
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == expectedEventSig) {
                eventFound = true;
                break;
            }
        }

        // Vulnerability verdict
        if (eventFound) {
            console.log("Vulnerability not Exist: ExcludeEnabledUpdated event was emitted");
        } else {
            console.log("Vulnerability Exists: ExcludeEnabledUpdated event missing");
        }
        
        assertFalse(eventFound, "ExcludeEnabledUpdated event should not be present");
        vm.stopPrank();
    }

    function test_setEnableTaxOnlyForSell_missing_event() public {
        vm.startPrank(owner);
        vm.recordLogs();
        token.setEnableTaxOnlyForSell(true);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        bytes32 expectedEventSig = keccak256("EnableTaxOnlyForSellUpdated(bool)");
        bool eventFound = false;
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == expectedEventSig) {
                eventFound = true;
                break;
            }
        }

        // Vulnerability verdict
        if (eventFound) {
            console.log("Vulnerability not Exist: EnableTaxOnlyForSellUpdated event was emitted");
        } else {
            console.log("Vulnerability Exists: EnableTaxOnlyForSellUpdated event missing");
        }
        
        assertFalse(eventFound, "EnableTaxOnlyForSellUpdated event should not be present");
        vm.stopPrank();
    }

    function test_setEnableTaxOnlyForTransfer_missing_event() public {
        vm.startPrank(owner);
        vm.recordLogs();
        token.setEnableTaxOnlyForTransfer(true);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        bytes32 expectedEventSig = keccak256("EnableTaxOnlyForTransferUpdated(bool)");
        bool eventFound = false;
        for (uint256 i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == expectedEventSig) {
                eventFound = true;
                break;
            }
        }

        // Vulnerability verdict
        if (eventFound) {
            console.log("Vulnerability not Exist: EnableTaxOnlyForTransferUpdated event was emitted");
        } else {
            console.log("Vulnerability Exists: EnableTaxOnlyForTransferUpdated event missing");
        }
        
        assertFalse(eventFound, "EnableTaxOnlyForTransferUpdated event should not be present");
        vm.stopPrank();
    }
}