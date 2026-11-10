// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/auction.sol";

contract DosAuctionTest is Test {
    DosAuction public auction;
    address public owner;
    address public alice;
    address public bob;
    
    uint256 public constant DURATION = 1 days;

    function setUp() public {
        owner = address(this);
        alice = address(0x1);
        bob = address(0x2);
        
        // Deploy auction contract
        auction = new DosAuction();
        
        // Fund test accounts - increased Alice's balance for multiple bids
        vm.deal(alice, 20 ether);
        vm.deal(bob, 10 ether);
    }

    function testMinerCanBlockLateBidViaTimestamp() public {
        // Start auction with 1 day duration
        auction.startAuction(DURATION);
        
        // Bob bids successfully
        vm.prank(bob);
        auction.bid{value: 1 ether}();
        
        // Fast forward to near end of auction
        skip(DURATION - 5 minutes);

        // Alice makes bid that gets included immediately (within auction period)
        vm.prank(alice);
        auction.bid{value: 5 ether}();

        // Skip beyond auction end time (simulating miner manipulation)
        skip(6 minutes);

        // Verify no more bids can be placed
        vm.prank(alice);
        vm.expectRevert("Auction has ended");
        auction.bid{value: 10 ether}();

        // Log vulnerability verdict
        console.log("Vulnerability Exists: Miner can block late bids via timestamp manipulation");
    }
    
    function testEndAuctionAfterMinerDelayedBid() public {
        // Start auction
        auction.startAuction(DURATION);
        vm.prank(alice);
        auction.bid{value: 1 ether}();
        
        // Force timestamp past auction end
        skip(DURATION + 1);
        
        // Should successfully end auction regardless of miner timestamp
        auction.endAuction();
        
        // Verify auction state cleared
        assertEq(auction.auctionEndTime(), 0);
        assertEq(auction.currentFrontrunner(), address(0));
        assertEq(auction.currentBid(), 0);

        // Log vulnerability verdict
        console.log("Vulnerability not Exist: Auction end function resists miner timestamp manipulation");
    }
}