pragma solidity ^0.8.26;

contract DosAuction {
    address public currentFrontrunner;
    uint256 public currentBid;
    uint256 public auctionEndTime;
    uint256 public totalBids;
    mapping(address => uint256) public bidCount;

    event NewBid(address indexed bidder, uint256 amount);
    event AuctionEnded(address indexed winner, uint256 winningBid);

    function bid() public payable {
        require(msg.value > currentBid, "Bid must be higher than current bid");
        require(block.timestamp < auctionEndTime, "Auction has ended");

        if (currentFrontrunner != address(0)) {
            require(payable(currentFrontrunner).send(currentBid));
        }

        currentFrontrunner = msg.sender;
        currentBid = msg.value;
        totalBids++;
        bidCount[msg.sender]++;

        emit NewBid(msg.sender, msg.value);
    }

    function startAuction(uint256 duration) public {
        require(auctionEndTime == 0, "Auction already started");
        auctionEndTime = block.timestamp + duration;
    }

    function endAuction() public {
        require(block.timestamp >= auctionEndTime, "Auction not yet ended");
        require(auctionEndTime != 0, "Auction not started");
        
        emit AuctionEnded(currentFrontrunner, currentBid);
        auctionEndTime = 0;
        currentFrontrunner = address(0);
        currentBid = 0;
    }
}