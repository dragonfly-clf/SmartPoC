// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import {stdError} from "forge-std/StdError.sol";
import {console2} from "forge-std/console2.sol"; // console2 provides richer logging
import "../src/simple_suicide.sol";

contract SimpleSuicideTest is Test {
    SimpleSuicide private vault;
    address private user = address(0x1);
    uint256 private constant MAX_UINT = type(uint256).max;

    function setUp() public {
        vault = new SimpleSuicide();
        vm.deal(user, 10 ether);
    }

    function testDepositCausesOverflow() public {
        // Set state variables to overflow-prone state
        uint256 totalDepositsSlot = 1;  // Slot index for totalDeposits
        uint256 mappingBaseSlot = 2;    // Base slot for userBalances mapping

        // Set totalDeposits to MAX_UINT - 1
        vm.store(
            address(vault),
            bytes32(totalDepositsSlot),
            bytes32(MAX_UINT - 1)
        );

        // Correct mapping slot calculation for userBalances
        bytes32 userBalanceSlot = keccak256(
            abi.encode(user, mappingBaseSlot)
        );
        vm.store(
            address(vault),
            userBalanceSlot,
            bytes32(MAX_UINT - 1)
        );

        // Verify storage modifications
        assertEq(vault.totalDeposits(), MAX_UINT - 1, "totalDeposits incorrect");
        assertEq(vault.userBalances(user), MAX_UINT - 1, "userBalances incorrect");

        console2.log("--- BEFORE-Trigger Deposit ---");
        uint256 preTotalDeposits = vault.totalDeposits();
        uint256 preUserBalances = vault.userBalances(user);
        console2.log("Initial totalDeposits:", preTotalDeposits);
        console2.log("Initial userBalances:", preUserBalances);
        console2.log("");

        console2.log("--- Trigger Deposit (Expected Revert) ---");
        // Attempt to deposit 2 wei (should overflow)
        vm.startPrank(user);
        vm.expectRevert(stdError.arithmeticError);
        vault.deposit{value: 2}();
        vm.stopPrank();

        console2.log("--- AFTER-Trigger Deposit ---");
        uint256 postTotalDeposits = vault.totalDeposits();
        uint256 postUserBalances = vault.userBalances(user);
        console2.log("Final totalDeposits:", postTotalDeposits);
        console2.log("Final userBalances:", postUserBalances);
        console2.log("");

        // Vulnerability verdict
        bool stateChanged = (preTotalDeposits != postTotalDeposits) || 
                           (preUserBalances != postUserBalances);
        
        console2.log("--- RESULT: Differential Verification ---");
        console2.log("State changed:", stateChanged ? "YES" : "NO");
        if (stateChanged) {
            console2.log("Vulnerability Exists: deposit operation corrupted state via overflow");
        } else {
            console2.log("Vulnerability not Exist: state preserved due to failed overflow operation");
        }
    }
}