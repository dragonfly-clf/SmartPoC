// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xaae1f51cf3339f18b6d3f3bdc75a5facd744b0b8.sol";

contract DEP_BANKTest is Test {
    DEP_BANK public depBank;
    LogFile public logFile;
    address user = address(0x123);

    function setUp() public {
        // Deploy contracts
        logFile = new LogFile();
        depBank = new DEP_BANK();
        
        // Setup contracts
        depBank.SetLogFile(address(logFile));
        vm.deal(user, 10 ether);
    }

    function test_DepositOverflow() public {
        // Force-set user's balance to max uint256
        bytes32 balanceSlot = keccak256(abi.encode(user, uint256(0)));
        vm.store(address(depBank), balanceSlot, bytes32(type(uint256).max));

        console.log("--- BEFORE-Trigger Balance ---");
        uint256 preBalance = depBank.balances(user);
        console.log("User balance before deposit:", preBalance);
        assertEq(preBalance, type(uint256).max, "Initial balance incorrect");

        console.log("--- Trigger Deposit ---");
        // Trigger overflow with 1 wei deposit
        vm.startPrank(user);
        depBank.Deposit{value: 1}();
        vm.stopPrank();

        console.log("--- AFTER-Trigger Balance ---");
        uint256 postBalance = depBank.balances(user);
        console.log("User balance after deposit:", postBalance);

        // Vulnerability check
        if (postBalance == 0) {
            console.log("Vulnerability Exists: Balance overflow occurred from max to zero");
        } else {
            console.log("Vulnerability not Exist: Balance did not overflow to zero");
        }
    }
}