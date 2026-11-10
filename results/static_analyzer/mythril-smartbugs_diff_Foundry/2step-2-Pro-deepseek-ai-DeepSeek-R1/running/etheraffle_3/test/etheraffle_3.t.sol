// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/etheraffle.sol";

contract EthraffleKillTest is Test {
    Ethraffle_v4b raffle;
    address payable owner = payable(address(0x1));
    address attacker = address(0x2);
 
    function setUp() public {
        vm.startPrank(owner);
        raffle = new Ethraffle_v4b();
        vm.stopPrank();
        
        // Fund the contract for destruction test
        vm.deal(address(raffle), 1 ether);
    }

    function test_owner_can_kill() public {
        uint256 ownerBalanceBefore = owner.balance;
        uint256 contractBalance = address(raffle).balance;

        vm.prank(owner);
        raffle.kill();

        // Verify contract destruction
        assertEq(address(raffle).balance, 0, "Contract should have 0 balance");
        assertEq(
            owner.balance,
            ownerBalanceBefore + contractBalance,
            "Owner should receive contract balance"
        );
    }

    function test_non_owner_cannot_kill() public {
        console2.log("--- BEFORE-Trigger ---");
        uint256 contractBalanceBefore = address(raffle).balance;
        uint256 ownerBalanceBefore = owner.balance;
        console2.log("Contract Balance", contractBalanceBefore);
        console2.log("Owner Balance", ownerBalanceBefore);

        console2.log("--- Trigger (non-owner kill call) ---");
        vm.prank(attacker);
        raffle.kill(); // Should do nothing if secure

        console2.log("--- AFTER-Trigger ---");
        uint256 contractBalanceAfter = address(raffle).balance;
        uint256 ownerBalanceAfter = owner.balance;
        console2.log("Contract Balance", contractBalanceAfter);
        console2.log("Owner Balance", ownerBalanceAfter);

        bool contractChanged = contractBalanceAfter != contractBalanceBefore;
        bool ownerChanged = ownerBalanceAfter != ownerBalanceBefore;
        bool stateChanged = contractChanged || ownerChanged;

        if (stateChanged) {
            console2.log("Vulnerability Exists: non-owner successfully destroyed contract and stole funds");
        } else {
            console2.log("Vulnerability not Exist: contract state remains secure after attack attempt");
        }

        assertEq(contractBalanceAfter, contractBalanceBefore, "Contract balance should remain unchanged");
        assertEq(ownerBalanceAfter, ownerBalanceBefore, "Owner balance should remain unchanged");
    }
}