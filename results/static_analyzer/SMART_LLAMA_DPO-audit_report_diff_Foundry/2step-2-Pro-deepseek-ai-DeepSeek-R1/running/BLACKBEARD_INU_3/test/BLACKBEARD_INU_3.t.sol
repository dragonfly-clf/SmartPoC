// SPDX-License-Identifier: MIT
pragma solidity 0.8.5;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/BLACKBEARD_INU.sol";

contract BLACKBEARD_INU_EventTest is Test {
    BLACKBEARD_INU token;

    function setUp() public {
        // Define addresses for router, WBNB, factory and pair
        address ROUTER_ADDRESS = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
        address WBNB_ADDRESS = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
        address mockFactory = address(0x123);
        address mockPair = address(0x456);

        // Mock router.factory() to return mockFactory
        vm.mockCall(
            ROUTER_ADDRESS,
            abi.encodeWithSignature("factory()"),
            abi.encode(mockFactory)
        );

        // Mock factory.createPair() to return mockPair
        vm.mockCall(
            mockFactory,
            abi.encodeWithSignature("createPair(address,address)"),
            abi.encode(mockPair)
        );

        // Deploy the token contract
        token = new BLACKBEARD_INU();
    }

    function hasTransferEvent(Vm.Log[] memory logs) internal pure returns (bool) {
        bytes32 transferTopic = keccak256("Transfer(address,address,uint256)");
        for (uint i = 0; i < logs.length; i++) {
            if (logs[i].topics[0] == transferTopic) {
                return true;
            }
        }
        return false;
    }

    function test_setSwapBackSettings_NoTransferEvent() public {
        console.log("--- BEFORE-Trigger: Log state ---");
        console.log("Expecting: No Transfer events emitted during state update");

        console.log("--- Trigger: setSwapBackSettings(true, 1000 ether) ---");
        vm.recordLogs();
        token.setSwapBackSettings(true, 1000 ether);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        console.log("--- AFTER-Trigger: Log verification ---");
        bool hasTransfer = hasTransferEvent(logs);
        console.log("Transfer event detected:", hasTransfer ? "YES" : "NO");

        if (hasTransfer) {
            console.log("Vulnerability Exists: Transfer event emitted during state update");
        } else {
            console.log("Vulnerability not Exist: No Transfer event detected");
        }
    }

    function test_setTargetLiquidity_NoTransferEvent() public {
        console.log("--- BEFORE-Trigger: Log state ---");
        console.log("Expecting: No Transfer events emitted during state update");

        console.log("--- Trigger: setTargetLiquidity(50, 100) ---");
        vm.recordLogs();
        token.setTargetLiquidity(50, 100);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        console.log("--- AFTER-Trigger: Log verification ---");
        bool hasTransfer = hasTransferEvent(logs);
        console.log("Transfer event detected:", hasTransfer ? "YES" : "NO");

        if (hasTransfer) {
            console.log("Vulnerability Exists: Transfer event emitted during state update");
        } else {
            console.log("Vulnerability not Exist: No Transfer event detected");
        }
    }

    function test_setAutoBuybackSettings_NoTransferEvent() public {
        console.log("--- BEFORE-Trigger: Log state ---");
        console.log("Expecting: No Transfer events emitted during state update");

        console.log("--- Trigger: setAutoBuybackSettings(true, 1000 ether, 100 ether, 100, true) ---");
        vm.recordLogs();
        token.setAutoBuybackSettings(true, 1000 ether, 100 ether, 100, true);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        console.log("--- AFTER-Trigger: Log verification ---");
        bool hasTransfer = hasTransferEvent(logs);
        console.log("Transfer event detected:", hasTransfer ? "YES" : "NO");

        if (hasTransfer) {
            console.log("Vulnerability Exists: Transfer event emitted during state update");
        } else {
            console.log("Vulnerability not Exist: No Transfer event detected");
        }
    }

    function test_setBuybackMultiplierSettings_NoTransferEvent() public {
        console.log("--- BEFORE-Trigger: Log state ---");
        console.log("Expecting: No Transfer events emitted during state update");

        console.log("--- Trigger: setBuybackMultiplierSettings(3, 2, 100) ---");
        vm.recordLogs();
        token.setBuybackMultiplierSettings(3, 2, 100);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        console.log("--- AFTER-Trigger: Log verification ---");
        bool hasTransfer = hasTransferEvent(logs);
        console.log("Transfer event detected:", hasTransfer ? "YES" : "NO");

        if (hasTransfer) {
            console.log("Vulnerability Exists: Transfer event emitted during state update");
        } else {
            console.log("Vulnerability not Exist: No Transfer event detected");
        }
    }

    function test_setDistributionCriteria_NoTransferEvent() public {
        console.log("--- BEFORE-Trigger: Log state ---");
        console.log("Expecting: No Transfer events emitted during state update");

        console.log("--- Trigger: setDistributionCriteria(100, 1 ether) ---");
        vm.recordLogs();
        token.setDistributionCriteria(100, 1 ether);
        Vm.Log[] memory logs = vm.getRecordedLogs();

        console.log("--- AFTER-Trigger: Log verification ---");
        bool hasTransfer = hasTransferEvent(logs);
        console.log("Transfer event detected:", hasTransfer ? "YES" : "NO");

        if (hasTransfer) {
            console.log("Vulnerability Exists: Transfer event emitted during state update");
        } else {
            console.log("Vulnerability not Exist: No Transfer event detected");
        }
    }
}