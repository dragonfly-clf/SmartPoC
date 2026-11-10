pragma solidity ^0.8.26;

contract OddsAndEvens {
    struct Player {
        address addr;
        uint number;
    }

    Player[2] public players;
    uint8 tot;
    address owner;
    uint public totalGames;
    uint public totalWinners;
    mapping(address => uint) public playerWins;
    uint public houseFee = 100000000000000000; // 0.1 ETH fee per game

    event GameStarted(address player1, address player2);
    event WinnerDeclared(address winner, uint prize);
    event HouseFeeCollected(uint amount);

    constructor() {
        owner = msg.sender;
    }

    function play(uint number) public payable {
        if (msg.value != 1000000000000000000) revert();
        players[tot] = Player(msg.sender, number);
        tot++;
        totalGames++;

        if (tot == 2) {
            emit GameStarted(players[0].addr, players[1].addr);
            andTheWinnerIs();
        }
    }

    function andTheWinnerIs() private {
        bool res;
        uint n;
        unchecked {
            n = players[0].number + players[1].number;
        }
        
        address winner;
        if (n % 2 == 0) {
            winner = players[0].addr;
            res = payable(players[0].addr).send(1800000000000000000);
        } else {
            winner = players[1].addr;
            res = payable(players[1].addr).send(1800000000000000000);
        }
        
        totalWinners++;
        playerWins[winner]++;
        emit WinnerDeclared(winner, 1800000000000000000);

        delete players;
        tot = 0;
    }

    function getProfit() public {
        if (msg.sender != owner) revert();
        uint houseBalance = address(this).balance;
        bool res = payable(msg.sender).send(houseBalance);
        if (houseBalance > 0) {
            emit HouseFeeCollected(houseBalance);
        }
    }

    function getPlayerStats(address player) public view returns (uint wins, uint gamesPlayed) {
        wins = playerWins[player];
        // Note: games played would need additional mapping to track properly
        gamesPlayed = 0; // Placeholder - actual implementation would require more storage
    }
}