// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xe4eabdca81e31d9acbc4af76b30f532b6ed7f3bf.sol";

contract MockRevert {
    fallback() external payable {
        revert();
    }
}

contract HoneyUncheckedReturnTest is Test {
    Honey public honey;
    MockRevert public mock;

    address public owner = makeAddr("owner");

    function setUp() public {
        vm.prank(owner);
        honey = new Honey();

        mock = new MockRevert();
    }

    function test_CommandDoesNotRevertOnInnerCallFailure() public {
        uint256 amount = 1 ether;

        // BEFORE-Trigger: Log initial state
        console.log("--- BEFORE-Trigger Command ---");
        console.log("Querying Honey contract balance:");
        uint256 initialHoneyBalance = honey.getContractBalance();
        console.log("Honey contract balance: %s", initialHoneyBalance);
        console.log("Querying Mock contract balance:");
        uint256 initialMockBalance = address(mock).balance;
        console.log("Mock contract balance: %s", initialMockBalance);
        console.log("--------------------------------");

        // Transfer Ether to owner for transaction
        vm.deal(owner, amount);
        bytes memory data = abi.encodeWithSignature("dummy()");

        // Log trigger action
        console.log("--- Trigger Command ---");
        console.log("Executing Honey.Command with %s ETH and reverted data", amount / 1 ether);
        console.log("--------------------------------");

        // Trigger action
        vm.prank(owner);
        honey.Command{value: amount}(address(mock), data);

        // AFTER-Trigger: Log post state
        console.log("--- AFTER-Trigger Command ---");
        console.log("Querying Honey contract balance after:");
        uint256 afterHoneyBalance = honey.getContractBalance();
        console.log("Honey contract balance: %s", afterHoneyBalance);
        console.log("Querying Mock contract balance after:");
        uint256 afterMockBalance = address(mock).balance;
        console.log("Mock contract balance: %s", afterMockBalance);
        console.log("--------------------------------");

        // Compute changes
        uint256 honeyBalanceDiff = afterHoneyBalance - initialHoneyBalance;
        uint256 mockBalanceDiff = afterMockBalance - initialMockBalance;

        // Log changes
        console.log("State Changes:");
        console.log("Honey contract balance change: +%s", honeyBalanceDiff);
        console.log("Mock contract balance change: +%s", mockBalanceDiff);
        console.log("--------------------------------");

        // Vulnerability condition: Honey balance increased by amount AND Mock balance unchanged
        bool honeyBalanceIncreased = (honeyBalanceDiff == amount);
        bool mockBalanceUnchanged = (mockBalanceDiff == 0);
        bool exploitSuccess = honeyBalanceIncreased && mockBalanceUnchanged;

        console.log("Verification Result:");
        console.log("- Honey balance increased as expected: %s", honeyBalanceIncreased ? "YES" : "NO");
        console.log("- Mock balance remained unchanged    : %s", mockBalanceUnchanged ? "YES" : "NO");
        console.log("--------------------------------");

        // Final verdict
        if (exploitSuccess) {
            console.log("Vulnerability Exists: Honey balance increased by the sent amount while Mock balance remained unchanged, confirming successful state exploitation.");
        } else {
            console.log("Vulnerability not Exist: The expected state change (Honey increased + amount, Mock unchanged) did not occur.");
        }
    }
}