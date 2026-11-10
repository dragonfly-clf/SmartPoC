// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3f2ef511aa6e75231e4deafc7a3d2ecab3741de2.sol";

contract FailingReceiver {
    receive() external payable {
        revert("Force receive failure");
    }
}

contract WhaleGiveaway2Test is Test {
    WhaleGiveaway2 public giveaway;
    FailingReceiver public failingReceiver;
    address public owner = makeAddr("owner");

    function setUp() public {
        vm.startPrank(owner);
        giveaway = new WhaleGiveaway2();
        failingReceiver = new FailingReceiver();
        vm.deal(owner, 10 ether); // Fund owner with ETH
        vm.stopPrank();
    }

    function testUncheckedCall() public {
        vm.startPrank(owner);
        
        console2.log("--- BEFORE-Trigger State ---");
        uint256 initialOwnerBalance = owner.balance;
        uint256 initialReceiverBalance = address(failingReceiver).balance;
        uint256 initialGiveawayBalance = address(giveaway).balance;
        
        console2.log("Owner Balance (before):", initialOwnerBalance);
        console2.log("Receiver Balance (before):", initialReceiverBalance);
        console2.log("Giveaway Balance (before):", initialGiveawayBalance);

        console2.log("--- Trigger Command ---");
        // Attempt to send 1 ETH to failing receiver
        giveaway.Command{value: 1 ether}(address(failingReceiver), "");

        console2.log("--- AFTER-Trigger State ---");
        uint256 finalOwnerBalance = owner.balance;
        uint256 finalReceiverBalance = address(failingReceiver).balance;
        uint256 finalGiveawayBalance = address(giveaway).balance;

        console2.log("Owner Balance (after):", finalOwnerBalance);
        console2.log("Receiver Balance (after):", finalReceiverBalance);
        console2.log("Giveaway Balance (after):", finalGiveawayBalance);
        
        // Vulnerability conditions:
        bool ownerLostETH = finalOwnerBalance == initialOwnerBalance - 1 ether;
        bool receiverBalanceUnchanged = finalReceiverBalance == initialReceiverBalance;
        bool ethStuckInContract = finalGiveawayBalance == initialGiveawayBalance + 1 ether;
        bool vulnerabilityExists = ownerLostETH && receiverBalanceUnchanged && ethStuckInContract;
        
        console2.log("Balance Difference (Owner):", int(finalOwnerBalance) - int(initialOwnerBalance));
        console2.log("Balance Difference (Receiver):", int(finalReceiverBalance) - int(initialReceiverBalance));
        console2.log("Balance Difference (Giveaway):", int(finalGiveawayBalance) - int(initialGiveawayBalance));
        
        console2.log("Vulnerability conditions met: %s", vulnerabilityExists ? "YES" : "NO");
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: ETH stuck in contract while owner lost funds");
        } else {
            console2.log("Vulnerability not Exist: ETH properly handled during failed transaction");
        }
        
        vm.stopPrank();
    }
}