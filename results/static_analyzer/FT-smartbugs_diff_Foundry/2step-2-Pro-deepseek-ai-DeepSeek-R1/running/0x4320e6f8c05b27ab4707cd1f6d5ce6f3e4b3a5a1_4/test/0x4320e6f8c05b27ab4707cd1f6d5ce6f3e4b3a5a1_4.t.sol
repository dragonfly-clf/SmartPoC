// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4320e6f8c05b27ab4707cd1f6d5ce6f3e4b3a5a1.sol";

contract DepositTest is Test {
    ACCURAL_DEPOSIT public depositContract;
    LogFile public logContract;
    address public depositor = makeAddr("depositor");

    function setUp() public {
        // Deploy required contracts
        logContract = new LogFile();
        depositContract = new ACCURAL_DEPOSIT();
        
        // Initialize logging
        depositContract.SetLogFile(address(logContract));
    }

    function testFallbackAcceptsArbitraryDeposit() public {
        // Fund test address
        uint256 depositAmount = 1 ether;
        vm.deal(depositor, depositAmount);

        // BEFORE-TRIGGER SNAPSHOT
        console.log("--- BEFORE-Trigger ---");
        uint256 initialContractBalance = address(depositContract).balance;
        uint256 initialInternalBalance = depositContract.balances(depositor);
        console.log("Contract ETH Balance (initial):", initialContractBalance);
        console.log("Depositor Internal Balance (initial):", initialInternalBalance);

        // TRIGGER ATTACK
        console.log("--- Trigger Fallback Deposit ---");
        vm.startPrank(depositor);
        (bool success, ) = address(depositContract).call{value: depositAmount}("");
        vm.stopPrank();

        require(success, "Fallback function call failed");
        
        // AFTER-TRIGGER SNAPSHOT
        console.log("--- AFTER-Trigger ---");
        uint256 finalContractBalance = address(depositContract).balance;
        uint256 finalInternalBalance = depositContract.balances(depositor);
        console.log("Contract ETH Balance (final):", finalContractBalance);
        console.log("Depositor Internal Balance (final):", finalInternalBalance);
        
        // DIFFERENTIAL VERIFICATION
        console.log("--- Differential Results ---");
        bool contractBalanceChanged = (finalContractBalance == initialContractBalance + depositAmount);
        bool internalBalanceUnchanged = (finalInternalBalance == initialInternalBalance);
        console.log("Contract ETH balance increase:", contractBalanceChanged ? "YES" : "NO");
        console.log("Depositor internal balance unchanged:", internalBalanceUnchanged ? "YES" : "NO");

        // FINAL VULNERABILITY VERIFICATION
        if (contractBalanceChanged && internalBalanceUnchanged) {
            console.log("VULNERABILITY CONFIRMED: Funds deposited without internal balance update");
            console.log("Vulnerability Exists: Fallback function accepts arbitrary deposits without updating accounting balances");
        } else {
            string memory reason = "Accounting properly updated";
            if (!contractBalanceChanged) {
                reason = "Unexpected contract balance change";
            } else if (!internalBalanceUnchanged) {
                reason = "Internal balance updated (expected no change)";
            }
            console.log("Vulnerability not Exist: %s", reason);
        }
    }
}