// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/0x0cbe050f75bc8f8c2d6c0d249fea125fd6e1acc9.sol";

contract CallerTest is Test {
    Caller public caller;
    address public owner = address(0x1);
    
    // Helper contract that rejects ether transfers
    RejectingContract public rejectingContract;
    // Helper contract that accepts ether transfers
    AcceptingContract public acceptingContract;

    function setUp() public {
        vm.prank(owner);
        caller = new Caller();
        rejectingContract = new RejectingContract();
        acceptingContract = new AcceptingContract();
    }

    function testUncheckedCallVulnerability() public {
        console.log("--- BEFORE-Trigger call ---");
        // Get initial call counters
        uint256 initialTotalCalls = caller.totalCalls();
        uint256 initialSenderCallCount = caller.callCounts(address(this));
        console.log("initialTotalCalls: ", initialTotalCalls);
        console.log("initialSenderCallCount: ", initialSenderCallCount);

        console.log("--- Trigger: call rejectingContract ---");
        // Make the unchecked call to rejecting contract
        caller.callAddress(address(rejectingContract));

        console.log("--- AFTER-Trigger call ---");
        // Get updated call counters
        uint256 updatedTotalCalls = caller.totalCalls();
        uint256 updatedSenderCallCount = caller.callCounts(address(this));
        console.log("updatedTotalCalls: ", updatedTotalCalls);
        console.log("updatedSenderCallCount: ", updatedSenderCallCount);

        // Calculate counter differences
        uint256 totalCallsDiff = updatedTotalCalls - initialTotalCalls;
        uint256 senderCallCountDiff = updatedSenderCallCount - initialSenderCallCount;
        console.log("totalCalls difference: ", totalCallsDiff);
        console.log("callCounts difference: ", senderCallCountDiff);

        // Verify vulnerability exists when counters increment despite failed call
        if (totalCallsDiff == 1 && senderCallCountDiff == 1) {
            console.log("Vulnerability Exists: Counters incremented even though call failed");
        } else {
            console.log("Vulnerability not Exist: Counters not incremented on failed call");
        }
    }

    function testSuccessfulCall() public {
        // Get initial call counts
        uint256 initialTotalCalls = caller.totalCalls();
        uint256 initialSenderCallCount = caller.callCounts(address(this));
        
        // Make the unchecked call to accepting contract
        caller.callAddress(address(acceptingContract));
        
        // Get updated call counts
        uint256 updatedTotalCalls = caller.totalCalls();
        uint256 updatedSenderCallCount = caller.callCounts(address(this));
        
        // Verify that counters incremented
        assertEq(updatedTotalCalls, initialTotalCalls + 1, "Total calls should increment");
        assertEq(updatedSenderCallCount, initialSenderCallCount + 1, "Sender call count should increment");
    }
}

// Contract that will reject the call
contract RejectingContract {
    fallback() external payable {
        revert("This contract rejects payments");
    }
}

// Contract that will accept the call
contract AcceptingContract {
    fallback() external payable {}
}