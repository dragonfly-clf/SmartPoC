// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x93c32845fae42c83a70e5f06214c8433665c2ab5.sol";

contract MockLog {
    uint public callCount;
    bool public shouldFail;

    function setShouldFail(bool _shouldFail) external {
        shouldFail = _shouldFail;
    }

    function AddMessage(address, uint, string memory) external returns (bool) {
        callCount++;
        if (shouldFail) {
            return false;
        }
        return true;
    }
}

contract XWalletTest is Test {
    X_WALLET wallet;
    MockLog mockLog;
    address user = makeAddr("user");
    uint256 constant depositAmount = 1 ether;

    function setUp() public {
        mockLog = new MockLog();
        wallet = new X_WALLET(address(mockLog));
        vm.deal(user, depositAmount);
    }

    function test_LogFailureDuringPut() public {
        // Force log addition to fail
        mockLog.setShouldFail(true);
        
        // BEFORE: Record initial state
        uint initialBalance = address(wallet).balance;
        uint initialCallCount = mockLog.callCount();
        console.log("--- BEFORE-Trigger Balance and CallCount ---");
        console.log("Wallet Balance: ", initialBalance);
        console.log("Call Count: ", initialCallCount);

        console.log("--- Trigger Deposit ---");
        // Deposit funds - should succeed despite log failure
        vm.prank(user);
        wallet.Put{value: depositAmount}(0);
        
        // AFTER: Record final state
        uint finalBalance = address(wallet).balance;
        uint finalCallCount = mockLog.callCount();
        console.log("--- AFTER-Trigger Balance and CallCount ---");
        console.log("Wallet Balance: ", finalBalance);
        console.log("Call Count: ", finalCallCount);
        
        // Calculate state changes
        uint balanceDiff = finalBalance - initialBalance;
        uint callCountDiff = finalCallCount - initialCallCount;
        console.log("Balance Change: ", balanceDiff);
        console.log("Call Count Change: ", callCountDiff);
        
        // Determine if vulnerability exists
        if (balanceDiff == depositAmount && callCountDiff == 1) {
            console.log("Vulnerability Exists: Put function successfully processed deposit despite log failure");
        } else {
            console.log("Vulnerability not Exist: Log failure prevented successful deposit execution");
        }

        // Verify funds were deposited
        assertEq(
            address(wallet).balance,
            initialBalance + depositAmount,
            "ETH deposit failed"
        );
        
        // Verify log attempt was made
        assertEq(
            mockLog.callCount(),
            initialCallCount + 1,
            "Log call was not made"
        );
    }
}