// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xb7c5c5aa4d42967efe906e1b66cb8df9cebf04f7.sol";

contract KeepMyEtherTest is Test {
    keepMyEther public kme;
    address public user = makeAddr("user");

    function setUp() public {
        kme = new keepMyEther();
    }

    function test_zeroValueDeposit() public {
        // Get initial state values
        (, uint256 initialDepositCount) = kme.getUserStats(user);
        uint256 initialTotalDeposits = kme.totalDeposits();
        
        console.log("--- BEFORE-Trigger State ---");
        console.log("User deposit count: ", initialDepositCount);
        console.log("Total deposits: ", initialTotalDeposits);

        console.log("--- Trigger Zero Value Deposit ---");
        // Send 0 ETH to trigger the receive function
        vm.deal(user, 0 ether);
        vm.prank(user);
        (bool success,) = address(kme).call{value: 0}("");
        require(success, "Call failed");

        console.log("--- AFTER-Trigger State ---");
        // Get state after zero value deposit
        (, uint256 newDepositCount) = kme.getUserStats(user);
        uint256 newTotalDeposits = kme.totalDeposits();
        console.log("User deposit count: ", newDepositCount);
        console.log("Total deposits: ", newTotalDeposits);
        
        // Compare state changes
        bool depositCountIncreased = (newDepositCount == initialDepositCount + 1);
        bool totalDepositsUnchanged = (newTotalDeposits == initialTotalDeposits);
        bool vulnerabilityExists = depositCountIncreased && totalDepositsUnchanged;
        
        // Print verification verdict
        if (vulnerabilityExists) {
            console.log("Vulnerability Exists: Deposit count increased by 1 while total deposits remained unchanged");
        } else {
            console.log("Vulnerability not Exist: State changes do not match vulnerability conditions");
        }
    }
}