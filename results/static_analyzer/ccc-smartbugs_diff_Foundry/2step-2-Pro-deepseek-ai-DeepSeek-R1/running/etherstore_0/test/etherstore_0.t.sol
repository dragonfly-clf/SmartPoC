// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/etherstore.sol";

contract EtherStoreTest is Test {
    EtherStore public store;
    address public depositor = makeAddr("depositor");

    function setUp() public {
        vm.deal(depositor, 1 ether);
        store = new EtherStore();
        
        // Set initial timestamp to enable first withdrawal
        vm.warp(1 weeks);
    }

    function testTimestampManipulationBypassesCooldown() public {
        vm.startPrank(depositor);
        
        // Deposit funds
        store.depositFunds{value: 1 ether}();
        
        // First withdrawal to set initial cooldown
        store.withdrawFunds(0.01 ether);
        uint256 firstWithdrawTime = block.timestamp;
        
        // Manipulate timestamp to bypass cooldown
        uint256 manipulatedTimestamp = firstWithdrawTime + 1 weeks;
        vm.warp(manipulatedTimestamp);
        
        // Differential state queries BEFORE second withdrawal
        console2.log("--- BEFORE SECOND WITHDRAWAL ---");
        uint256 contractBalanceBefore = store.getContractBalance();
        uint256 userBalanceBefore = store.getUserBalance(depositor);
        uint256 totalWithdrawalsBefore = store.totalWithdrawals();
        
        console2.log("Contract balance before: ", contractBalanceBefore);
        console2.log("User balance before: ", userBalanceBefore);
        console2.log("Total withdrawals before: ", totalWithdrawalsBefore);
        
        console2.log("--- TRIGGER: Second Withdrawal ---");
        // Second withdrawal operation
        store.withdrawFunds(0.01 ether);
        
        // Differential state queries AFTER second withdrawal
        console2.log("--- AFTER SECOND WITHDRAWAL ---");
        uint256 contractBalanceAfter = store.getContractBalance();
        uint256 userBalanceAfter = store.getUserBalance(depositor);
        uint256 totalWithdrawalsAfter = store.totalWithdrawals();
        
        console2.log("Contract balance after: ", contractBalanceAfter);
        console2.log("User balance after: ", userBalanceAfter);
        console2.log("Total withdrawals after: ", totalWithdrawalsAfter);
        
        // Calculate state changes
        uint256 contractBalanceChange = contractBalanceBefore - contractBalanceAfter;
        uint256 userBalanceChange = userBalanceBefore - userBalanceAfter;
        uint256 totalWithdrawalsChange = totalWithdrawalsAfter - totalWithdrawalsBefore;
        
        console2.log("Contract balance change: ", contractBalanceChange);
        console2.log("User balance change: ", userBalanceChange);
        console2.log("Withdrawals change: ", totalWithdrawalsChange);
        
        // Expected state changes (each should be 0.01 ether if successful)
        bool balancesChangedAsExpected = 
            contractBalanceChange == 0.01 ether &&
            userBalanceChange == 0.01 ether &&
            totalWithdrawalsChange == 0.01 ether;
        
        // Differential verdict
        if (balancesChangedAsExpected) {
            console2.log("VULNERABILITY VERDICT: State changed exactly as expected. Second withdrawal bypassed cooldown via timestamp manipulation");
            console2.log("Vulnerability Exists: Timestamp manipulation bypassed withdrawal cooldown");
        } else {
            console2.log("VULNERABILITY VERDICT: State did not change as expected. Cooldown mechanism remains effective");
            console2.log("Vulnerability not Exist: Second withdrawal did not bypass cooldown");
        }

        // Verify final balances
        uint256 contractBalance = store.getContractBalance();
        assertEq(contractBalance, 0.98 ether, "Contract balance incorrect");
        
        uint256 userBalance = store.getUserBalance(depositor);
        assertEq(userBalance, 0.98 ether, "User balance incorrect");
        
        vm.stopPrank();
    }
}