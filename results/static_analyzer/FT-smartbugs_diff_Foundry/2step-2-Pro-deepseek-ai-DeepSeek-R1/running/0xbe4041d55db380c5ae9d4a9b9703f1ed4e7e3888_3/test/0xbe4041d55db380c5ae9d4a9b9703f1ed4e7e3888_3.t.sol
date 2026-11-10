// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xbe4041d55db380c5ae9d4a9b9703f1ed4e7e3888.sol";

contract MoneyBoxTest is Test {
    MONEY_BOX public moneyBox;
    Log public logContract; // Renamed to avoid conflict
    address public user = makeAddr("user");

    function setUp() public {
        // Deploy required contracts
        logContract = new Log();
        moneyBox = new MONEY_BOX();

        // Initialize dependencies
        moneyBox.SetLogFile(address(logContract));
    }

    // Test zero-value deposit vulnerability
    function test_zeroValueDeposit() public {
        vm.deal(user, 1 ether);
        
        console.log("--- BEFORE-Trigger zeroValueDeposit ---");
        (uint beforeBalance, uint beforeUnlockTime) = moneyBox.Acc(user);
        console.log("User balance before:", beforeBalance);
        console.log("Unlock time before:", beforeUnlockTime);

        console.log("--- Trigger zeroValueDeposit ---");
        vm.prank(user);
        moneyBox.Put{value: 0}(0);

        console.log("--- AFTER-Trigger zeroValueDeposit ---");
        (uint afterBalance, uint afterUnlockTime) = moneyBox.Acc(user);
        console.log("User balance after:", afterBalance);
        console.log("Unlock time after:", afterUnlockTime);

        // Vulnerability verification
        if (beforeUnlockTime != afterUnlockTime && afterUnlockTime != 0) {
            console.log("Vulnerability Exists: Zero-value deposit created a box with non-zero unlock time");
        } else {
            console.log("Vulnerability not Exist: No improper state change detected");
        }
    }

    // Test huge lock time vulnerability
    function test_hugeLockTime() public {
        vm.deal(user, 1 ether);
        uint lockTime = 1e9;
        uint beforeTimestamp = block.timestamp;
        
        console.log("--- BEFORE-Trigger hugeLockTime ---");
        (uint beforeBalance, uint beforeUnlockTime) = moneyBox.Acc(user);
        console.log("User balance before:", beforeBalance);
        console.log("Unlock time before:", beforeUnlockTime);

        console.log("--- Trigger hugeLockTime (locktime=%s) ---", lockTime);
        vm.prank(user);
        moneyBox.Put{value: 1 ether}(lockTime);

        console.log("--- AFTER-Trigger hugeLockTime ---");
        (uint afterBalance, uint afterUnlockTime) = moneyBox.Acc(user);
        console.log("User balance after:", afterBalance);
        console.log("Unlock time after:", afterUnlockTime);

        // Vulnerability verification
        uint expectedUnlockTime = beforeTimestamp + lockTime;
        if (afterUnlockTime == expectedUnlockTime && afterBalance == 1 ether) {
            console.log("Vulnerability Exists: Huge lock time (%s seconds) accepted", lockTime);
        } else {
            console.log("Vulnerability not Exist: Unlock time not set as expected");
        }
    }
}