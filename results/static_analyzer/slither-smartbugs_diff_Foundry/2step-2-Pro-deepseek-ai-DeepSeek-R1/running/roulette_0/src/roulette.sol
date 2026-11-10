pragma solidity ^0.8.26;

contract Roulette {
    uint public pastBlockTime;
    address public owner;
    uint public totalGames;
    uint public totalWinners;
    mapping(address => uint) public playerWins;

    event GamePlayed(address indexed player, bool won, uint prize);
    event FundsDeposited(address indexed depositor, uint amount);

    constructor() payable {
        owner = msg.sender;
    }

    function deposit() external payable {
        emit FundsDeposited(msg.sender, msg.value);
    }

    function placeBet() external payable {
        require(msg.value == 10 ether, "Bet must be exactly 10 ETH");
        require(block.timestamp != pastBlockTime, "Only one bet per block allowed");
        
        pastBlockTime = block.timestamp;
        totalGames++;
        
        if(block.timestamp % 15 == 0) {
            uint prize = address(this).balance;
            payable(msg.sender).transfer(prize);
            totalWinners++;
            playerWins[msg.sender]++;
            emit GamePlayed(msg.sender, true, prize);
        } else {
            emit GamePlayed(msg.sender, false, 0);
        }
    }

    function withdrawOwnerShare() external {
        require(msg.sender == owner, "Only owner can withdraw");
        uint balance = address(this).balance;
        uint ownerShare = balance / 10;
        payable(owner).transfer(ownerShare);
    }
}