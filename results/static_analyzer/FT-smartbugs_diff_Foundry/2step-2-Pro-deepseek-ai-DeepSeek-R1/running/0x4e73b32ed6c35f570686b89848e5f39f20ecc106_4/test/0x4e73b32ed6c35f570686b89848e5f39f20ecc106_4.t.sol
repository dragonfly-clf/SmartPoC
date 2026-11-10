// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import {Test} from "forge-std/Test.sol";
import "../src/0x4e73b32ed6c35f570686b89848e5f39f20ecc106.sol";

contract PRIVATE_ETH_CELL_Test is Test {
    PRIVATE_ETH_CELL privateEthCell;
    LogFile logFile;
    
    function setUp() public {
        privateEthCell = new PRIVATE_ETH_CELL();
        logFile = new LogFile();
    }

    // Allow this test contract to receive ETH
    receive() external payable { }

    // Test that Deposit() reverts when Log is uninitialized
    function test_DepositRevertsWhenLogUninitialized() public {
        vm.deal(address(this), 1 ether);
        
        emit log("--- Trigger Deposit with Uninitialized Log ---");
        try privateEthCell.Deposit{value: 1 ether}() {
            emit log("--- Result: DID NOT REVERT ---");
            emit log("Vulnerability Exists: Deposit should revert when Log is uninitialized");
        } catch {
            emit log("--- Result: REVERTED ---");
            emit log("Vulnerability not Exist: Deposit reverts as expected when Log is uninitialized");
        }
    }

    // Test that Collect() reverts due to uninitialized Log
    function test_CollectFailsDueToUninitializedLog() public {
        // Initialize Log to enable deposit
        privateEthCell.SetLogFile(address(logFile));
        
        // Deposit funds - using fallback to mimic actual usage
        vm.deal(address(this), 1 ether);
        (bool success, ) = address(privateEthCell).call{value: 1 ether}("");
        require(success, "Deposit failed");

        // Set log to uninitialized state
        privateEthCell.SetLogFile(address(0));

        emit log("--- Trigger Collect with Uninitialized Log ---");
        try privateEthCell.Collect(1 ether) {
            emit log("--- Result: DID NOT REVERT ---");
            emit log("Vulnerability Exists: Collect should revert when Log is uninitialized");
        } catch {
            emit log("--- Result: REVERTED ---");
            emit log("Vulnerability not Exist: Collect reverts as expected when Log is uninitialized");
        }
    }
}