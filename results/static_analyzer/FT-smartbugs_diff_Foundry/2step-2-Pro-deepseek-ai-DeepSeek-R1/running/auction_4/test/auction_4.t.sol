// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/auction.sol";

contract DosAuctionTest is Test {
    DosAuction public auction;
    address public alice = address(0xA11CE);
    address public bob = address(0xB0B);

    function setUp() public {
        auction = new DosAuction();
        deal(alice, 10 ether);
        deal(bob, 10 ether);
    }

    // Test demonstrating missing refund mechanism
    function test_FrontrunnerCannotWithdrawExcess() public {
        // Start auction
        auction.startAuction(1 days);
        
        // Alice bids 1 ether
        vm.prank(alice);
        auction.bid{value: 1 ether}();
        
        // Bob bids 3 ether
        vm.prank(bob);
        auction.bid{value: 3 ether}();
        
        // Time-travel past auction end time
        vm.warp(block.timestamp + 1 days + 1);
        
        // Check balances before auction ends
        uint256 auctionBalanceBefore = address(auction).balance;
        uint256 bobBalanceBefore = address(bob).balance;
        console.log("--- BEFORE-Trigger EndAuction ---");
        console.log("Auction contract balance: %s", auctionBalanceBefore);
        console.log("Bob balance: %s", bobBalanceBefore);

        console.log("--- Trigger EndAuction ---");
        // End auction
        auction.endAuction();
        
        // Check balances after auction
        uint256 auctionBalanceAfter = address(auction).balance;
        uint256 bobBalanceAfter = address(bob).balance;
        console.log("--- AFTER-Trigger EndAuction ---");
        console.log("Auction contract balance: %s", auctionBalanceAfter);
        console.log("Bob balance: %s", bobBalanceAfter);

        // Verify if refund occurred (auction balance should decrease)
        if (auctionBalanceAfter == auctionBalanceBefore) {
            console.log("Vulnerability Exists: No refund occurred to losing bidder");
        } else {
            console.log("Vulnerability not Exist: Refund occurred properly");
        }
    }
}