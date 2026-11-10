// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/auction.sol";

contract AuctionTimestampTest is Test {
    DosAuction public auction;
    address public constant OWNER = address(1);
    address public constant BIDDER1 = address(2);
    address public constant BIDDER2 = address(3);
    
    uint public constant DURATION = 100;
    uint public auctionStartTime;

    event NewBid(address indexed bidder, uint amount);
    event AuctionEnded(address indexed winner, uint amount);

    function setUp() public {
        vm.deal(OWNER, 1 ether);
        vm.deal(BIDDER1, 5 ether);
        vm.deal(BIDDER2, 5 ether);
        
        vm.prank(OWNER);
        auction = new DosAuction();
        
        vm.prank(OWNER);
        auction.startAuction(DURATION);
        
        auctionStartTime = block.timestamp;
    }

    function test_bidSucceedsOneSecondBeforeEnd() public {
        // Warp to 1 second before auction end
        vm.warp(auctionStartTime + DURATION - 1);
        
        console.log("--- BEFORE-Trigger Bid ---");
        // Record auction state before placing bid
        address frontrunnerBefore = auction.currentFrontrunner();
        uint currentBidBefore = auction.currentBid();
        uint totalBidsBefore = auction.totalBids();
        console.log("Frontrunner: %s, CurrentBid: %s, TotalBids: %s", 
                    frontrunnerBefore, currentBidBefore, totalBidsBefore);
        
        console.log("--- Trigger Bid ---");
        vm.prank(BIDDER1);
        auction.bid{value: 1 ether}();
        
        console.log("--- AFTER-Trigger Bid ---");
        // Record auction state after placing bid
        address frontrunnerAfter = auction.currentFrontrunner();
        uint currentBidAfter = auction.currentBid();
        uint totalBidsAfter = auction.totalBids();
        console.log("Frontrunner: %s, CurrentBid: %s, TotalBids: %s", 
                    frontrunnerAfter, currentBidAfter, totalBidsAfter);
        
        // Check for expected state changes
        bool stateUpdatedCorrectly = (frontrunnerAfter == BIDDER1) && 
                                     (currentBidAfter == 1 ether) && 
                                     (totalBidsAfter == totalBidsBefore + 1);
        
        if (stateUpdatedCorrectly) {
            console.log("Vulnerability not Exist: Bid state updated correctly");
        } else {
            console.log("Vulnerability Exists: Bid state not updated correctly");
        }
        
        // Verify bid was accepted via auction ending
        vm.startPrank(OWNER);
        vm.warp(auctionStartTime + DURATION); // Move to exact end time
        vm.expectEmit(true, true, true, true, address(auction));
        emit AuctionEnded(BIDDER1, 1 ether);
        auction.endAuction();
        vm.stopPrank();
    }

    function test_bidFailsAtExactEndTime() public {
        // Warp to exact auction end time
        vm.warp(auctionStartTime + DURATION);
        
        vm.prank(BIDDER1);
        vm.expectRevert("Auction has ended");
        auction.bid{value: 1 ether}();
    }

    function test_endAuctionFailsBeforeEndTime() public {
        // Try to end auction before it has ended
        vm.warp(auctionStartTime + DURATION - 1);
        vm.expectRevert("Auction not yet ended");
        vm.prank(OWNER);
        auction.endAuction();
    }
}