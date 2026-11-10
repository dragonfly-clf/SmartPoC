pragma solidity ^0.8.26;

contract Lottery {
    event GetBet(uint betAmount, uint blockNumber, bool won);
    event BetPlaced(address indexed player, uint amount, bool won);
    event PrizeClaimed(address indexed winner, uint amount);

    struct Bet {
        uint betAmount;
        uint blockNumber;
        bool won;
    }

    address private organizer;
    Bet[] private bets;
    mapping(address => uint) public playerWins;
    uint public totalBets;
    uint public totalWinners;

    constructor() {
        organizer = msg.sender;
    }

    fallback() external {
        revert();
    }

    function makeBet() public payable {
        require(msg.value > 0, "Bet amount must be greater than 0");
        
        bool won = (block.number % 2) == 0;
        bets.push(Bet(msg.value, block.number, won));
        totalBets++;
        
        if(won) {
            totalWinners++;
            playerWins[msg.sender]++;
            if(!payable(msg.sender).send(msg.value)) {
                revert();
            }
            emit PrizeClaimed(msg.sender, msg.value);
        }
        
        emit BetPlaced(msg.sender, msg.value, won);
    }

    function getBets() public {
        if(msg.sender != organizer) { revert(); }
        for (uint i = 0; i < bets.length; i++) {
            emit GetBet(bets[i].betAmount, bets[i].blockNumber, bets[i].won);
        }
    }

    function destroy() public {
        if(msg.sender != organizer) { revert(); }
        selfdestruct(payable(organizer));
    }

    function getPlayerStats(address player) public view returns (uint wins, uint totalPlayerBets) {
        wins = playerWins[player];
        totalPlayerBets = 0;
        for (uint i = 0; i < bets.length; i++) {
            if (msg.sender == player) {
                totalPlayerBets++;
            }
        }
    }
}