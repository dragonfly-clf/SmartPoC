// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbe4041d55db380c5ae9d4a9b9703f1ed4e7e3888.sol";

contract MoneyBoxTimestampTest is Test {
    MONEY_BOX moneyBox;
    Log logContract;
    address user = makeAddr("user");
    uint256 constant SAFE_TIMESTAMP_BASE = 1000000;
    uint256 constant depositAmount = 1 ether;
    uint256 constant lockPeriod = 1 days;
    
    function setUp() public {
        logContract = new Log();
        moneyBox = new MONEY_BOX();
        moneyBox.SetLogFile(address(logContract));
        moneyBox.SetMinSum(0);
        vm.deal(user, 1 ether);

        vm.warp(SAFE_TIMESTAMP_BASE);
        vm.prank(user);
        moneyBox.Put{value: depositAmount}(lockPeriod);
    }

    function testTimestampManipulation() public {
        // Simulation 1: Withdraw BEFORE unlock time (1 sec before)
        vm.warp(SAFE_TIMESTAMP_BASE + lockPeriod - 1);
        console2.log("--- BEFORE-Trigger Simulation1 (BEFORE unlock time) ---");
        uint256 contractBalancePre1 = address(moneyBox).balance;
        uint256 userBalancePre1 = user.balance;
        console2.log("Contract balance (pre):", contractBalancePre1);
        console2.log("User balance (pre):", userBalancePre1);

        console2.log("--- Trigger Simulation1: Withdraw attempt BEFORE unlock ---");
        vm.prank(user);
        moneyBox.Collect(depositAmount);

        console2.log("--- AFTER-Trigger Simulation1 (BEFORE unlock time) ---");
        uint256 contractBalancePost1 = address(moneyBox).balance;
        uint256 userBalancePost1 = user.balance;
        console2.log("Contract balance (post):", contractBalancePost1);
        console2.log("User balance (post):", userBalancePost1);
        
        uint256 withdrawalOccurred1 = contractBalancePre1 - contractBalancePost1;
        console2.log("Funds withdrawn in Simulation1:", withdrawalOccurred1);
        console2.log("Result: Withdrawal %s in Simulation1",
            withdrawalOccurred1 > 0 ? "SUCCEEDED (unexpected)" : "FAILED (expected)"
        );
        require(contractBalancePost1 == contractBalancePre1, "Contract balance should not change");
        require(userBalancePost1 == userBalancePre1, "User balance should not change");

        // Simulation 2: Withdraw AT EXACT unlock time
        vm.warp(SAFE_TIMESTAMP_BASE + lockPeriod);
        console2.log("\n--- BEFORE-Trigger Simulation2 (AT unlock time) ---");
        uint256 contractBalancePre2 = address(moneyBox).balance;
        uint256 userBalancePre2 = user.balance;
        console2.log("Contract balance (pre):", contractBalancePre2);
        console2.log("User balance (pre):", userBalancePre2);

        console2.log("--- Trigger Simulation2: Withdraw attempt AT unlock ---");
        vm.prank(user);
        moneyBox.Collect(depositAmount);

        console2.log("--- AFTER-Trigger Simulation2 (AT unlock time) ---");
        uint256 contractBalancePost2 = address(moneyBox).balance;
        uint256 userBalancePost2 = user.balance;
        console2.log("Contract balance (post):", contractBalancePost2);
        console2.log("User balance (post):", userBalancePost2);
        
        uint256 withdrawalOccurred2 = contractBalancePre2 - contractBalancePost2;
        console2.log("Funds withdrawn in Simulation2:", withdrawalOccurred2);
        console2.log("Result: Withdrawal %s in Simulation2",
            withdrawalOccurred2 > 0 ? "SUCCEEDED (unexpected)" : "FAILED (expected)"
        );
        require(contractBalancePost2 == contractBalancePre2, "Contract balance should not change");
        require(userBalancePost2 == userBalancePre2, "User balance should not change");

        // Simulation 3: Withdraw AFTER unlock time (1 sec after)
        vm.warp(SAFE_TIMESTAMP_BASE + lockPeriod + 1);
        console2.log("\n--- BEFORE-Trigger Simulation3 (AFTER unlock time) ---");
        uint256 contractBalancePre3 = address(moneyBox).balance;
        uint256 userBalancePre3 = user.balance;
        console2.log("Contract balance (pre):", contractBalancePre3);
        console2.log("User balance (pre):", userBalancePre3);

        console2.log("--- Trigger Simulation3: Withdraw attempt AFTER unlock ---");
        vm.prank(user);
        moneyBox.Collect(depositAmount);

        console2.log("--- AFTER-Trigger Simulation3 (AFTER unlock time) ---");
        uint256 contractBalancePost3 = address(moneyBox).balance;
        uint256 userBalancePost3 = user.balance;
        console2.log("Contract balance (post):", contractBalancePost3);
        console2.log("User balance (post):", userBalancePost3);
        
        uint256 withdrawalOccurred3 = contractBalancePre3 - contractBalancePost3;
        console2.log("Funds withdrawn in Simulation3:", withdrawalOccurred3);
        console2.log("Result: Withdrawal %s in Simulation3",
            withdrawalOccurred3 > 0 ? "SUCCEEDED (expected)" : "FAILED (unexpected)"
        );
        require(contractBalancePost3 == contractBalancePre3 - depositAmount, "Contract balance should decrease");
        require(userBalancePost3 == userBalancePre3 + depositAmount, "User balance should increase");

        // Vulnerability assessment
        bool earlyWithdrawalSuccess = (withdrawalOccurred1 > 0) || (withdrawalOccurred2 > 0);
        
        if (earlyWithdrawalSuccess) {
            console2.log("\nVulnerability Exists: Contract allowed early withdrawal before lock period ended");
        } else {
            console2.log("\nVulnerability not Exist: Contract correctly prevented early withdrawals");
        }
    }
}