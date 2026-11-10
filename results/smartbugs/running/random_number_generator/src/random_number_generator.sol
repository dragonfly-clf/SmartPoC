pragma solidity ^0.8.26;

contract RandomNumberGenerator {
    uint256 private salt = block.timestamp;
    uint256 public totalGames;
    uint256 public winningNumber;
    mapping(address => uint256) public playerBets;
    mapping(address => uint256) public playerWins;

    event GamePlayed(address indexed player, uint256 bet, uint256 result, bool won);
    event WinningNumberSet(uint256 number);

    function random(uint256 max) private view returns (uint256 result) {
        unchecked {
            uint256 x = salt * 100 / max;
            uint256 y = salt * block.number / (salt % 5);
            uint256 seed = block.number / 3 + (salt % 300) + y;
            uint256 h = uint256(blockhash(seed));
            return uint256((h / x)) % max + 1;
        }
    }

    function playGame(uint256 bet) external {
        require(bet > 0, "Bet must be greater than 0");
        
        playerBets[msg.sender] = bet;
        totalGames++;
        
        uint256 randomResult = random(100);
        winningNumber = randomResult;
        
        bool won = (randomResult % 10 == 0);
        if (won) {
            playerWins[msg.sender]++;
        }
        
        emit GamePlayed(msg.sender, bet, randomResult, won);
        emit WinningNumberSet(randomResult);
    }

    function getPlayerStats(address player) external view returns (uint256 bets, uint256 wins) {
        return (playerBets[player], playerWins[player]);
    }
}