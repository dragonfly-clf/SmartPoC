// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0xd5967fed03e85d1cce44cab284695b41bc675b5c.sol";

contract MockToken {
    // Always return false for transferFrom to simulate failure
    function transferFrom(address, address, uint256) external pure returns (bool) {
        return false;
    }
}

contract TransferTest is Test {
    demo tokenUtil;
    MockToken mockToken;
    
    constructor() {
        tokenUtil = new demo();
        mockToken = new MockToken();
    }

    function testTransfer_FailedCallUpdatesState() public {
        address ALICE = address(0x1);
        address[] memory recipients = new address[](1);
        recipients[0] = address(0x2);
        uint256 value = 100;

        console.log("--- BEFORE-Trigger State ---");
        // Record state before transfer attempt
        uint256 beforeTotalTransfer = tokenUtil.totalTransfers(recipients[0]);
        uint256 beforeUserTransfer = tokenUtil.userTransfers(ALICE, recipients[0]);
        console.log("[State] beforeTotalTransfer: %s", beforeTotalTransfer);
        console.log("[State] beforeUserTransfer: %s", beforeUserTransfer);

        // Perform transfer attempt (expected to fail)
        console.log("--- Trigger Transfer ---");
        bool success = tokenUtil.transfer(ALICE, address(mockToken), recipients, value);
        console.log("Transfer call result: %s", success);
        assertTrue(success, "Call should return true");

        console.log("--- AFTER-Trigger State ---");
        // Record state after transfer attempt
        uint256 afterTotalTransfer = tokenUtil.totalTransfers(recipients[0]);
        uint256 afterUserTransfer = tokenUtil.userTransfers(ALICE, recipients[0]);
        console.log("[State] afterTotalTransfer: %s", afterTotalTransfer);
        console.log("[State] afterUserTransfer: %s", afterUserTransfer);

        // Vulnerability check - state should remain unchanged after failed transfer
        bool stateChanged = (beforeTotalTransfer != afterTotalTransfer) || 
                            (beforeUserTransfer != afterUserTransfer);
        
        console.log("[Verdict] State change after failed transfer:", stateChanged);
        if (stateChanged) {
            console.log("Vulnerability Exists: State variables updated despite transferFrom failure");
        } else {
            console.log("Vulnerability not Exist: State remains unchanged after failed transfer");
        }
    }
}