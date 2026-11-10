// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/Allin.sol";

contract AllinTest is Test {
    Allin token;
    address constant ROUTER = 0x10ED43C718714eb63d5aA57B78B54704E256024E;
    address constant WBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address dummyPair = address(0xdead);
    
    // Event signature for Transfer event
    bytes32 constant TRANSFER_EVENT_SIGNATURE = keccak256("Transfer(address,address,uint256)");

    function setUp() public {
        // Mock router.factory() call
        vm.mockCall(
            ROUTER,
            abi.encodeWithSelector(IDEXRouter.factory.selector),
            abi.encode(address(this))  // Return test contract as factory
        );
        
        // Mock factory.createPair() call
        vm.mockCall(
            address(this),
            abi.encodeWithSelector(IDEXFactory.createPair.selector),
            abi.encode(dummyPair)
        );
        
        token = new Allin();
    }

    // Fixed: removed view modifier to avoid state modification errors
    function hasUnexpectedTransferEvent() internal returns (bool) {
        Vm.Log[] memory entries = vm.getRecordedLogs();
        for (uint256 i = 0; i < entries.length; i++) {
            if (entries[i].emitter != address(token)) continue;
            if (entries[i].topics.length > 0 && entries[i].topics[0] == TRANSFER_EVENT_SIGNATURE) {
                return true;
            }
        }
        return false;
    }

    function test_setSwapBackSettings_MissingTransferEvent() public {
        console.log("--- BEFORE-Trigger: No logs recorded ---");
        vm.recordLogs();

        console.log("--- Trigger: setSwapBackSettings ---");
        token.setSwapBackSettings(true, 1000 ether);

        console.log("--- AFTER-Trigger: Checking logs ---");
        if (hasUnexpectedTransferEvent()) {
            console.log("Vulnerability Exists: Unexpected Transfer event emitted during setSwapBackSettings");
        } else {
            console.log("Vulnerability not Exist: No unexpected Transfer event during setSwapBackSettings");
        }
    }

    function test_setTargetLiquidity_MissingTransferEvent() public {
        console.log("--- BEFORE-Trigger: No logs recorded ---");
        vm.recordLogs();

        console.log("--- Trigger: setTargetLiquidity ---");
        token.setTargetLiquidity(500, 1000);

        console.log("--- AFTER-Trigger: Checking logs ---");
        if (hasUnexpectedTransferEvent()) {
            console.log("Vulnerability Exists: Unexpected Transfer event emitted during setTargetLiquidity");
        } else {
            console.log("Vulnerability not Exist: No unexpected Transfer event during setTargetLiquidity");
        }
    }

    function test_setTxLimit_MissingTransferEvent() public {
        console.log("--- BEFORE-Trigger: No logs recorded ---");
        vm.recordLogs();

        console.log("--- Trigger: setTxLimit ---");
        token.setTxLimit(token.totalSupply() / 1000);  // Minimum allowed value

        console.log("--- AFTER-Trigger: Checking logs ---");
        if (hasUnexpectedTransferEvent()) {
            console.log("Vulnerability Exists: Unexpected Transfer event emitted during setTxLimit");
        } else {
            console.log("Vulnerability not Exist: No unexpected Transfer event during setTxLimit");
        }
    }

    function test_setDistributionCriteria_MissingTransferEvent() public {
        console.log("--- BEFORE-Trigger: No logs recorded ---");
        vm.recordLogs();

        console.log("--- Trigger: setDistributionCriteria ---");
        // Use dummy parameters within valid ranges
        token.setDistributionCriteria(1 hours, 1 ether);

        console.log("--- AFTER-Trigger: Checking logs ---");
        if (hasUnexpectedTransferEvent()) {
            console.log("Vulnerability Exists: Unexpected Transfer event emitted during setDistributionCriteria");
        } else {
            console.log("Vulnerability not Exist: No unexpected Transfer event during setDistributionCriteria");
        }
    }
}