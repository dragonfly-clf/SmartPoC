// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x4b71ad9c1a84b9b643aa54fdd66e2dec96e8b152.sol";

contract MockToken {
    bool public transferSuccess;
    constructor(bool _transferSuccess) {
        transferSuccess = _transferSuccess;
    }

    function transferFrom(address, address, uint256) external returns (bool) {
        return transferSuccess;
    }
}

contract AirPortIssuesTest is Test {
    airPort public ap;
    MockToken public failingToken;
    address from;
    address caddress;
    uint256 transferAmount;
    address[] recipients;

    function setUp() public {
        ap = new airPort();
        failingToken = new MockToken(false); // false = always fail transfers
        
        from = address(0x1);
        caddress = address(failingToken);
        transferAmount = 100;
        recipients = new address[](2);
        recipients[0] = address(0x2);
        recipients[1] = address(0x3);
    }

    function testTransfersStillUpdateStateOnFailure() public {
        console2.log("--- BEFORE-Trigger Transfer ---");
        // Record initial state values
        uint256 beforeTokenTransfer = ap.userTokenTransfers(from, caddress);
        uint256 beforeTotalCount = ap.totalTransfers(from);
        console2.log("Before: userTokenTransfers =", beforeTokenTransfer);
        console2.log("Before: totalTransfers =", beforeTotalCount);

        console2.log("--- Trigger Transfer ---");
        // Attempt a token transfer (will fail)
        ap.transfer(from, caddress, recipients, transferAmount);

        console2.log("--- AFTER-Trigger Transfer ---");
        // Record state after transfer operation
        uint256 afterTokenTransfer = ap.userTokenTransfers(from, caddress);
        uint256 afterTotalCount = ap.totalTransfers(from);
        console2.log("After: userTokenTransfers =", afterTokenTransfer);
        console2.log("After: totalTransfers =", afterTotalCount);

        // Emissions test
        vm.expectEmit(true, true, true, true);
        emit airPort.BulkTransfer(from, caddress, transferAmount, recipients.length);
        
        // Return value test
        assertEq(ap.transfer(from, caddress, recipients, transferAmount), true);

        // Vulnerability verification
        uint256 expectedTokenTransfer = beforeTokenTransfer + transferAmount * recipients.length;
        uint256 expectedTotalCount = beforeTotalCount + recipients.length;
        bool stateUpdated = (afterTokenTransfer == expectedTokenTransfer) && 
                            (afterTotalCount == expectedTotalCount);
        
        console2.log("State updated despite transfer failure:", stateUpdated ? "YES" : "NO");
        if (stateUpdated) {
            console2.log("Vulnerability Exists: State variables updated even on transfer failure");
        } else {
            console2.log("Vulnerability not Exist: State variables not updated on transfer failure");
        }
    }
}