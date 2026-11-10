// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etherbank.sol";

contract EtherBankTest is Test {
    EtherBank public bank;
    address owner = makeAddr("owner");
    
    function setUp() public {
        vm.startPrank(owner);
        bank = new EtherBank();
        vm.stopPrank();
    }

    function testSmallBalancesReceiveNoInterest() public {
        // Deposit small amount (99 wei)
        address user = makeAddr("smallUser");
        vm.deal(user, 99);
        vm.prank(user);
        bank.addToBalance{value: 99}();

        console2.log("--- BEFORE-Trigger Interest Payment ---");
        uint initialBalance = bank.getBalance(user);
        console2.log("Balance: %d", initialBalance);
        assertEq(initialBalance, 99);

        console2.log("--- Trigger Interest Payment ---");
        vm.prank(owner);
        bank.payInterest(user);

        console2.log("--- AFTER-Trigger Interest Payment ---");
        uint finalBalance = bank.getBalance(user);
        console2.log("Balance: %d", finalBalance);
        assertEq(finalBalance, 99, "User should receive no interest on 99 wei");

        // Vulnerability verdict
        if (finalBalance > initialBalance) {
            console2.log("Vulnerability not Exist: User unexpectedly received interest");
        } else {
            console2.log("Vulnerability Exists: User received no interest due to rounding down");
        }
    }

    function testPrecisionLossWithDifferentAmounts() public {
        // Test case 1: 1 wei deposit
        console2.log("========= Testing deposit: 1 wei =========");
        testInterestCalculation(1, 0);
        
        // Test case 2: 99 wei deposit
        console2.log("========= Testing deposit: 99 wei =========");
        testInterestCalculation(99, 0);
        
        // Test case 3: 100 wei deposit
        console2.log("========= Testing deposit: 100 wei =========");
        testInterestCalculation(100, 1);
        
        // Test case 4: 101 wei deposit
        console2.log("========= Testing deposit: 101 wei =========");
        testInterestCalculation(101, 1);

        console2.log("Vulnerability Exists: Integer division causes precision loss on small balances across all test cases");
    }

    function testInterestCalculation(uint depositAmount, uint expectedInterest) private {
        // Create unique user address for each test case
        address user = address(uint160(uint256(keccak256(abi.encodePacked(depositAmount)))));
        vm.deal(user, depositAmount);
        
        // Deposit funds
        vm.prank(user);
        bank.addToBalance{value: depositAmount}();
        
        console2.log("--- BEFORE-Trigger Interest Payment ---");
        uint initialBalance = bank.getBalance(user);
        console2.log("Deposit: %d | Balance: %d", depositAmount, initialBalance);
        assertEq(initialBalance, depositAmount, "Initial balance mismatch");
        
        console2.log("--- Trigger Interest Payment ---");
        vm.prank(owner);
        bank.payInterest(user);
        
        console2.log("--- AFTER-Trigger Interest Payment ---");
        uint finalBalance = bank.getBalance(user);
        console2.log("Balance: %d | Interest Paid: %d", finalBalance, finalBalance - initialBalance);
        
        uint expectedBalance = depositAmount + expectedInterest;
        console2.log("Expected Balance: %d | Actual Balance: %d", expectedBalance, finalBalance);
        
        assertEq(
            finalBalance,
            expectedBalance,
            string(abi.encodePacked("Interest calculation failed for deposit: ", vm.toString(depositAmount)))
        );
    }
}