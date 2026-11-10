// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/auction.sol";

contract DosAuctionTest is Test {
    DosAuction public auction;
    
    function setUp() public {
        auction = new DosAuction();
    }

    function test_StartAuctionOverflow() public {
        // Get current timestamp
        uint256 currentTimestamp = block.timestamp;
        
        // Calculate duration that would cause arithmetic overflow:
        // auctionEndTime = currentTimestamp + duration
        uint256 overflowDuration = type(uint256).max - currentTimestamp + 1;
        
        console2.log("--- BEFORE-Trigger State ---");
        console2.log("Prepared overflow duration: %s", overflowDuration);
        
        console2.log("--- Trigger StartAuction ---");
        console2.log("Attempting to start auction with overflow duration...");
        vm.expectRevert();
        auction.startAuction(overflowDuration);
        
        console2.log("--- AFTER-Trigger State ---");
        console2.log("Transaction successfully reverted as expected");
        console2.log("Vulnerability Exists: Arithmetic overflow causes revert during auction start");
    }
}