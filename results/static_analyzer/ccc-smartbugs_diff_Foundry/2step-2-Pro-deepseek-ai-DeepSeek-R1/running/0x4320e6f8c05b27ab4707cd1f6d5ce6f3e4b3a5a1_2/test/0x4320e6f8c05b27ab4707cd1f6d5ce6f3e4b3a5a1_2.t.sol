// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4320e6f8c05b27ab4707cd1f6d5ce6f3e4b3a5a1.sol";

contract MockLog {
    function AddMessage(address, uint256, string memory) public {}
}

contract ACCURAL_DEPOSIT_Test is Test {
    ACCURAL_DEPOSIT public depositContract;
    MockLog public mockLog;
    address constant user = address(0x123);

    function setUp() public {
        mockLog = new MockLog();
        depositContract = new ACCURAL_DEPOSIT();

        depositContract.SetLogFile(address(mockLog));
        vm.deal(user, 100 ether);
    }

    function test_OverflowVulnerability() public {
        // Set user's initial balance to max uint256
        bytes32 baseSlot = bytes32(uint256(0));  // Assuming balances mapping at slot 0
        bytes32 userSlot = keccak256(abi.encode(user, baseSlot));
        bytes32 maxBalance = bytes32(type(uint256).max);
        vm.store(address(depositContract), userSlot, maxBalance);

        // BEFORE snapshot: Query initial state
        console2.log("--- BEFORE-Trigger State ---");
        uint256 initialBalance = depositContract.balances(user);
        console2.log("Initial Balance: ", initialBalance);
        assertEq(initialBalance, type(uint256).max, "Initial balance not max");

        // TRIGGER: Execute deposit to cause overflow
        console2.log("--- Trigger Operation ---");
        console2.log("Executing: depositContract.Deposit{value: 1}()");
        vm.prank(user);
        depositContract.Deposit{value: 1}();

        // AFTER snapshot: Query final state
        console2.log("--- AFTER-Trigger State ---");
        uint256 finalBalance = depositContract.balances(user);
        console2.log("Final Balance: ", finalBalance);

        // Differential verification
        console2.log("--- Vulnerability Verdict ---");
        if (initialBalance == type(uint256).max && finalBalance == 0) {
            console2.log("Vulnerability Exists: Deposit caused balance overflow from max to zero");
        } else if (initialBalance != type(uint256).max) {
            console2.log("Vulnerability not Exist: Failed to set initial balance to max uint256");
        } else {
            console2.log("Vulnerability not Exist: Overflow did not reset balance to zero");
        }
    }
}