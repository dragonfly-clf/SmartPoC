// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/auction.sol";

contract DosAuctionTest is Test {
    DosAuction public auction;
    address public constant BIDDER_1 = address(0x100);
    address public constant BIDDER_2 = address(0x200);

    function setUp() public {
        auction = new DosAuction();
        vm.deal(BIDDER_1, 10 ether);
        vm.deal(BIDDER_2, 10 ether);
    }

    // Helper to get current auction state
    function getState() public view returns (
        address frontrunner,
        uint256 highestBid,
        uint256 bidsTotal,
        uint256 bidder1Bids,
        uint256 bidder2Bids
    ) {
        frontrunner = auction.currentFrontrunner();
        highestBid = auction.currentBid();
        bidsTotal = auction.totalBids();
        bidder1Bids = auction.bidCount(BIDDER_1);
        bidder2Bids = auction.bidCount(BIDDER_2);
    }

    function test_BlockTimestampPredictability() public {
        // Start auction with known duration
        auction.startAuction(1 days);
        
        // Manipulate block timestamp during auction
        vm.warp(block.timestamp + 12 hours);
        
        // Get state before first bid
        (   address frontrunnerBeforeBid1,
            uint256 highestBidBeforeBid1,
            uint256 totalBidsBeforeBid1,
            uint256 bidder1BidsBeforeBid1,
            uint256 bidder2BidsBeforeBid1 
        ) = getState();

        console.log("--- BEFORE First Bid ---");
        console.log("Current Frontrunner:", frontrunnerBeforeBid1);
        console.log("Highest Bid:", highestBidBeforeBid1);
        console.log("Total Bids:", totalBidsBeforeBid1);
        console.log("BIDDER_1 Bid Count:", bidder1BidsBeforeBid1);
        console.log("BIDDER_2 Bid Count:", bidder2BidsBeforeBid1);

        console.log("--- Trigger First Bid (BIDDER_1 @ 1 ether) ---");
        vm.prank(BIDDER_1);
        auction.bid{value: 1 ether}();

        // Get state after first bid
        (   address frontrunnerAfterBid1,
            uint256 highestBidAfterBid1,
            uint256 totalBidsAfterBid1,
            uint256 bidder1BidsAfterBid1,
            uint256 bidder2BidsAfterBid1 
        ) = getState();

        console.log("--- AFTER First Bid ---");
        console.log("Current Frontrunner:", frontrunnerAfterBid1);
        console.log("Highest Bid:", highestBidAfterBid1);
        console.log("Total Bids:", totalBidsAfterBid1);
        console.log("BIDDER_1 Bid Count:", bidder1BidsAfterBid1);
        console.log("BIDDER_2 Bid Count:", bidder2BidsAfterBid1);

        // Get state before second bid
        (   address frontrunnerBeforeBid2,
            uint256 highestBidBeforeBid2,
            uint256 totalBidsBeforeBid2,
            uint256 bidder1BidsBeforeBid2,
            uint256 bidder2BidsBeforeBid2 
        ) = getState();

        console.log("--- BEFORE Second Bid ---");
        console.log("Current Frontrunner:", frontrunnerBeforeBid2);
        console.log("Highest Bid:", highestBidBeforeBid2);
        console.log("Total Bids:", totalBidsBeforeBid2);
        console.log("BIDDER_1 Bid Count:", bidder1BidsBeforeBid2);
        console.log("BIDDER_2 Bid Count:", bidder2BidsBeforeBid2);

        console.log("--- Trigger Second Bid (BIDDER_2 @ 2 ether) ---");
        // Record events after initial bid
        vm.recordLogs();
        vm.prank(BIDDER_2);
        auction.bid{value: 2 ether}();

        // Get state after second bid
        (   address frontrunnerAfterBid2,
            uint256 highestBidAfterBid2,
            uint256 totalBidsAfterBid2,
            uint256 bidder1BidsAfterBid2,
            uint256 bidder2BidsAfterBid2 
        ) = getState();

        console.log("--- AFTER Second Bid ---");
        console.log("Current Frontrunner:", frontrunnerAfterBid2);
        console.log("Highest Bid:", highestBidAfterBid2);
        console.log("Total Bids:", totalBidsAfterBid2);
        console.log("BIDDER_1 Bid Count:", bidder1BidsAfterBid2);
        console.log("BIDDER_2 Bid Count:", bidder2BidsAfterBid2);

        // Verify both bids succeeded using event count
        Vm.Log[] memory logs = vm.getRecordedLogs();
        assertEq(logs.length, 1, "Bids show deterministic outcome");

        // Final vulnerability check based on state changes
        bool vulnerabilityDetected = 
            frontrunnerAfterBid2 != BIDDER_2 || 
            highestBidAfterBid2 != 2 ether;

        if (vulnerabilityDetected) {
            console.log("Vulnerability Exists: Auction state corrupted - Second bid failed to update state (frontrunner=%s, highestBid=%s)", 
                        frontrunnerAfterBid2, highestBidAfterBid2);
        } else {
            console.log("Vulnerability not Exist: Auction state updated correctly - Frontrunner=%s, HighestBid=%s", 
                        frontrunnerAfterBid2, highestBidAfterBid2);
        }
    }
}