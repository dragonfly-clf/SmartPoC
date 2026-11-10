// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb37f18af15bafb869a065b61fc83cfc44ed9cc27.sol";

contract SimpleWalletTest is Test {
    SimpleWallet wallet;
    address user = makeAddr("user");

    function setUp() public {
        wallet = new SimpleWallet();
        vm.deal(user, 1 ether);
    }

    function test_DepositDoesNotEmitEvent() public {
        // State before deposit
        console.log("--- BEFORE-Trigger state ---");
        uint256 userDepositBefore = wallet.getUserDeposit(user);
        uint256 contractBalanceBefore = address(wallet).balance;
        console.log("User deposit before: %s", userDepositBefore);
        console.log("Contract balance before: %s", contractBalanceBefore);
        
        // Record events during deposit
        console.log("--- TRIGGER: Deposit 1 ether ---");
        vm.recordLogs();
        vm.prank(user);
        (bool success,) = address(wallet).call{value: 1 ether}("");
        require(success, "Deposit failed");
        Vm.Log[] memory logs = vm.getRecordedLogs();

        // State after deposit
        console.log("--- AFTER-Trigger state ---");
        uint256 userDepositAfter = wallet.getUserDeposit(user);
        uint256 contractBalanceAfter = address(wallet).balance;
        console.log("User deposit after: %s", userDepositAfter);
        console.log("Contract balance after: %s", contractBalanceAfter);
        console.log("Number of events emitted: %s", logs.length);

        // Validate state consistency (required for correct operation)
        bool stateCorrect = (userDepositAfter == userDepositBefore + 1 ether) && 
                           (contractBalanceAfter == contractBalanceBefore + 1 ether);
        require(stateCorrect, "State changed incorrectly");
        
        // Vulnerability determination
        bool eventMissing = (logs.length == 0);
        console.log("--- VERDICT ---");
        if (eventMissing) {
            console.log("Vulnerability Exists: State changes without event emission");
        } else {
            console.log("Vulnerability not Exist: State changes include proper event emission");
        }
    }
}