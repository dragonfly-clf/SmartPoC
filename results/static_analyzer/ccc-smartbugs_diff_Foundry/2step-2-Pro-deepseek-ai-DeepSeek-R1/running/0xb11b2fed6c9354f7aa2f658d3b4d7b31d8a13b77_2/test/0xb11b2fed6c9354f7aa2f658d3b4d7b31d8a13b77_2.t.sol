// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb11b2fed6c9354f7aa2f658d3b4d7b31d8a13b77.sol";

contract DepositProxyTest is Test {
    DepositProxy public depositProxy;
    address public owner = makeAddr("owner");
    uint256 public constant INITIAL_OWNER_BALANCE = 1 ether;
    uint256 public constant DEPOSIT_AMOUNT = 0.5 ether;

    function setUp() public {
        // Fund owner account
        vm.deal(owner, INITIAL_OWNER_BALANCE);
        
        vm.startPrank(owner);
        // Deploy while sending initial ETH to contract
        depositProxy = new DepositProxy{value: DEPOSIT_AMOUNT}();
        vm.stopPrank();
    }

    function test_WithdrawDenialOfService() public {
        // Verify contract has initial balance
        uint256 contractBalanceBefore = address(depositProxy).balance;
        assertEq(contractBalanceBefore, DEPOSIT_AMOUNT, "Contract should hold initial deposit");

        // Record additional state variables before the withdrawal
        uint256 depositOwnerBefore = depositProxy.Deposits(owner);
        uint256 totalDepositsBefore = depositProxy.totalDeposits();
        uint256 ownerBalanceBefore = owner.balance;

        console.log("--- BEFORE-Trigger Withdrawal ---");
        console.log("Contract Balance (before):", contractBalanceBefore);
        console.log("Owner Balance (before):", owner.balance);
        console.log("Owner Deposit (before):", depositOwnerBefore);
        console.log("Total Deposits (before):", totalDepositsBefore);

        // Track gas usage for withdrawal attempt
        uint256 gasBefore = gasleft();

        console.log("--- Trigger Withdrawal ---");
        // Attempt withdrawal as owner 
        vm.prank(owner);
        depositProxy.withdraw(DEPOSIT_AMOUNT);

        // Calculate actual gas used
        uint256 gasUsed = gasBefore - gasleft();

        console.log("--- AFTER-Trigger Withdrawal ---");
        // Verify contract balance remains unchanged
        uint256 contractBalanceAfter = address(depositProxy).balance;
        assertEq(contractBalanceAfter, DEPOSIT_AMOUNT, "Contract balance should remain locked");

        // Verify owner didn't receive ETH beyond gas cost
        uint256 ownerBalanceAfter = owner.balance;
        uint256 expectedBalanceAfter = ownerBalanceBefore - (gasUsed * tx.gasprice);
        assertEq(
            ownerBalanceAfter, 
            expectedBalanceAfter,
            "Owner should only pay gas, no ETH received"
        );

        // Get additional state variables after the withdrawal
        uint256 depositOwnerAfter = depositProxy.Deposits(owner);
        uint256 totalDepositsAfter = depositProxy.totalDeposits();
        
        console.log("Contract Balance (after):", contractBalanceAfter);
        console.log("Owner Balance (after):", ownerBalanceAfter);
        console.log("Owner Deposit (after):", depositOwnerAfter);
        console.log("Total Deposits (after):", totalDepositsAfter);

        // Differential verification logic
        if (depositOwnerAfter == depositOwnerBefore && totalDepositsAfter == totalDepositsBefore) {
            console.log("Vulnerability Exists: Deposit records remain unchanged, the withdrawal did not update state.");
        } else {
            console.log("Vulnerability not Exist: Deposit records or total deposits changed, withdrawal updated state.");
        }
    }
}