// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "forge-std/console2.sol";
import "../src/0x7a4349a749e59a5736efb7826ee3496a2dfd5489.sol";

contract Reverter {
    function fail() external payable {
        revert("Call failed");
    }
}

contract WhaleGiveaway1Test is Test {
    WhaleGiveaway1 giveaway;
    address constant BACKDOOR = 0x7a617c2B05d2A74Ff9bABC9d81E5225C1e01004b;
    address attacker = address(0x1337);
    uint256 initialBalance = 10 ether;

    Reverter reverter;

    function setUp() public {
        reverter = new Reverter();
        giveaway = new WhaleGiveaway1();
        
        // Fund the contract and relevant addresses
        vm.deal(address(giveaway), initialBalance);
        vm.deal(attacker, 1 ether);
        vm.deal(BACKDOOR, 10 ether);
    }

    function test_BackdoorDrainsFunds() public {
        console2.log("--- BEFORE-Trigger ---");
        uint256 giveawayBalanceBefore = address(giveaway).balance;
        uint256 backdoorBalanceBefore = BACKDOOR.balance;
        console2.log('Giveaway Balance Before:', giveawayBalanceBefore);
        console2.log('BACKDOOR Balance Before:', backdoorBalanceBefore);
        
        console2.log("--- Trigger: BACKDOOR withdraw ---");
        vm.prank(BACKDOOR);
        giveaway.withdraw();
        
        console2.log("--- AFTER-Trigger ---");
        uint256 giveawayBalanceAfter = address(giveaway).balance;
        uint256 backdoorBalanceAfter = BACKDOOR.balance;
        console2.log('Giveaway Balance After:', giveawayBalanceAfter);
        console2.log('BACKDOOR Balance After:', backdoorBalanceAfter);
        
        // Vulnerability verdict
        bool vulnerabilityExists = giveawayBalanceAfter == 0 && 
                                 backdoorBalanceAfter == backdoorBalanceBefore + giveawayBalanceBefore;
        console2.log('Contract drained:', vulnerabilityExists ? 'Yes' : 'No');
        console2.log("--- Verdict ---");
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Backdoor successfully drained contract");
        } else {
            console2.log("Vulnerability not Exist: Backdoor drain failed");
        }

        // Original assertions
        assertEq(address(giveaway).balance, 0, "Contract should be drained");
        assertEq(
            BACKDOOR.balance, 
            backdoorBalanceBefore + initialBalance,
            "Backdoor should receive funds"
        );
    }

    function test_RevertWhen_NonBackdoorWithdraws() public {
        console2.log("--- BEFORE-Trigger ---");
        uint256 giveawayBalanceBefore = address(giveaway).balance;
        uint256 attackerBalanceBefore = attacker.balance;
        console2.log('Giveaway Balance Before:', giveawayBalanceBefore);
        console2.log('Attacker Balance Before:', attackerBalanceBefore);
        
        console2.log("--- Trigger: Attacker withdraw attempt ---");
        vm.prank(attacker);
        vm.expectRevert();
        giveaway.withdraw();
        
        console2.log("--- AFTER-Trigger ---");
        uint256 giveawayBalanceAfter = address(giveaway).balance;
        uint256 attackerBalanceAfter = attacker.balance;
        console2.log('Giveaway Balance After:', giveawayBalanceAfter);
        console2.log('Attacker Balance After:', attackerBalanceAfter);
        
        // Vulnerability verdict
        bool vulnerabilityExists = !(giveawayBalanceAfter == giveawayBalanceBefore &&
                                  attackerBalanceAfter == attackerBalanceBefore);
        console2.log('Balances unchanged:', vulnerabilityExists ? 'No' : 'Yes');
        console2.log("--- Verdict ---");
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Non-backdoor access allowed");
        } else {
            console2.log("Vulnerability not Exist: Non-backdoor access blocked as expected");
        }

        // Original assertions
        assertEq(attacker.balance, attackerBalanceBefore, "Attacker balance unchanged");
        assertEq(
            address(giveaway).balance,
            giveawayBalanceBefore,
            "Contract balance unchanged"
        );
    }

    function test_CanExecuteArbitraryCalls() public {
        console2.log("--- BEFORE-Trigger ---");
        uint256 giveawayBalanceBefore = address(giveaway).balance;
        console2.log('Giveaway Balance Before:', giveawayBalanceBefore);
        
        console2.log("--- Trigger: BACKDOOR withdraw ---");
        vm.prank(BACKDOOR);
        giveaway.withdraw();
        
        address recipient = address(0xABCD);
        uint256 recipientBalanceBefore = recipient.balance;
        uint256 amount = 5 ether;
        console2.log('Recipient Balance Before:', recipientBalanceBefore);
        
        console2.log("--- Trigger: BACKDOOR Command transfer ---");
        vm.prank(BACKDOOR);
        giveaway.Command{value: amount}(recipient, "");
        
        console2.log("--- AFTER-Trigger ---");
        uint256 giveawayBalanceAfter = address(giveaway).balance;
        uint256 recipientBalanceAfter = recipient.balance;
        console2.log('Giveaway Balance After:', giveawayBalanceAfter);
        console2.log('Recipient Balance After:', recipientBalanceAfter);
        
        // Vulnerability verdict
        bool vulnerabilityExists = recipientBalanceAfter == recipientBalanceBefore + amount &&
                                 giveawayBalanceAfter == 0;
        console2.log('Funds transferred successfully:', vulnerabilityExists ? 'Yes' : 'No');
        console2.log("--- Verdict ---");
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Backdoor transferred funds via Command");
        } else {
            console2.log("Vulnerability not Exist: Command transfer failed");
        }

        // Original assertions
        assertEq(recipient.balance, recipientBalanceBefore + amount, "Recipient should receive funds");
        assertEq(address(giveaway).balance, 0, "Contract balance should be zero");
    }

    function test_ExternalCallFailureHoldsFunds() public {
        console2.log("--- Setup: BACKDOOR withdraw ---");
        vm.prank(BACKDOOR);
        giveaway.withdraw();
        
        console2.log("--- BEFORE-Trigger ---");
        uint256 giveawayBalanceBefore = address(giveaway).balance;
        uint256 backdoorBalanceBefore = BACKDOOR.balance;
        uint256 reverterBalanceBefore = address(reverter).balance;
        console2.log('Giveaway Balance Before:', giveawayBalanceBefore);
        console2.log('Backdoor Balance Before:', backdoorBalanceBefore);
        console2.log('Reverter Balance Before:', reverterBalanceBefore);
        
        console2.log("--- Trigger: BACKDOOR to Reverter ---");
        bytes memory data = abi.encodeWithSignature("fail()");
        vm.prank(BACKDOOR);
        giveaway.Command{value: 5 ether}(address(reverter), data);
        
        console2.log("--- AFTER-Trigger ---");
        uint256 giveawayBalanceAfter = address(giveaway).balance;
        uint256 backdoorBalanceAfter = BACKDOOR.balance;
        uint32 reverterBalanceAfter = uint32(address(reverter).balance); // Cast to avoid uint256 overflow
        console2.log('Giveaway Balance After:', giveawayBalanceAfter);
        console2.log('Backdoor Balance After:', backdoorBalanceAfter);
        console2.log('Reverter Balance After:', reverterBalanceAfter);
        
        // Vulnerability verdict
        bool vulnerabilityExists = giveawayBalanceAfter == giveawayBalanceBefore + 5 ether &&
                                 backdoorBalanceAfter == backdoorBalanceBefore - 5 ether &&
                                 address(reverter).balance == 0;
        console2.log('Funds held on failure:', vulnerabilityExists ? 'Yes' : 'No');
        console2.log("--- Verdict ---");
        if (vulnerabilityExists) {
            console2.log("Vulnerability Exists: Backdoor manipulated contract state via failed call");
        } else {
            console2.log("Vulnerability not Exist: Failed call handled correctly");
        }

        // Updated assertions
        assertEq(
            giveawayBalanceAfter,
            giveawayBalanceBefore + 5 ether,
            "Contract should hold failed transfer"
        );
        assertEq(
            backdoorBalanceAfter,
            backdoorBalanceBefore - 5 ether,
            "Backdoor should have sent funds"
        );
        assertEq(
            address(reverter).balance,
            0,
            "Reverter should not receive funds"
        );
    }
}