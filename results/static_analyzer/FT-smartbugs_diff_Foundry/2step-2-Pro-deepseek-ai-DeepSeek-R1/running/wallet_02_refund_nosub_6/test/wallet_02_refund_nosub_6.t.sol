// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/wallet_02_refund_nosub.sol";

contract WalletDepositTest is Test {
    Wallet public wallet;
    address public user = makeAddr("user");

    function setUp() public {
        wallet = new Wallet();
    }

    function test_ZeroValueDepositFails() public {
        // --- BEFORE-Trigger State Snapshot ---
        console.log("--- BEFORE-Trigger State Snapshot ---");
        uint256 initialContractBalance = address(wallet).balance;
        uint256 initialUserBalance = wallet.getBalance(user);
        uint256 initialDepositCount = wallet.depositCount(user);
        uint256 initialTotalDeposits = wallet.totalDeposits();
        
        console.log("Contract ETH balance (before):", initialContractBalance);
        console.log("User token balance (before):", initialUserBalance);
        console.log("Deposit count (before):", initialDepositCount);
        console.log("Total deposits (before):", initialTotalDeposits);
        
        // --- Trigger Action ---
        console.log("--- Trigger Action: Zero-value deposit call ---");
        vm.expectRevert(stdError.assertionError);
        vm.prank(user);
        wallet.deposit{value: 0}();

        // --- AFTER-Trigger State Snapshot ---
        console.log("--- AFTER-Trigger State Snapshot ---");
        uint256 afterContractBalance = address(wallet).balance;
        uint256 afterUserBalance = wallet.getBalance(user);
        uint256 afterDepositCount = wallet.depositCount(user);
        uint256 afterTotalDeposits = wallet.totalDeposits();
        
        console.log("Contract ETH balance (after):", afterContractBalance);
        console.log("User token balance (after):", afterUserBalance);
        console.log("Deposit count (after):", afterDepositCount);
        console.log("Total deposits (after):", afterTotalDeposits);
        
        // --- State Comparison ---
        console.log("--- State Comparison ---");
        bool stateChanged = (afterContractBalance != initialContractBalance) ||
            (afterUserBalance != initialUserBalance) ||
            (afterDepositCount != initialDepositCount) ||
            (afterTotalDeposits != initialTotalDeposits);
            
        console.log("State changed after zero-value deposit?", stateChanged ? "YES" : "NO");
        
        // Vulnerability exists only if state didn't change after non-reverted zero-value deposit
        bool vulnerabilityExists = !stateChanged;
        console.log("Vulnerability status:", vulnerabilityExists 
            ? "EXISTS - Zero-value deposit didn't change state" 
            : "DOES NOT EXIST - State changed or function reverted");
        
        // Final verdict using required format
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Contract allows zero-value deposits without state changes");
        } else {
            console.log("Vulnerability not Exist: Contract properly reverts or changes state with zero-value deposits");
        }
    }
}