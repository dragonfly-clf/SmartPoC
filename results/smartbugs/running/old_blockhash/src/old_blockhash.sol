pragma solidity ^0.8.26;

contract PredictTheBlockHashChallenge {

    struct guess{
      uint block;
      bytes32 guess;
    }

    mapping(address => guess) guesses;
    uint public totalGames;
    uint public totalWinners;
    mapping(address => uint) public playerWins;
    
    event GamePlayed(address indexed player, bool won, uint prize);
    event GuessLocked(address indexed player, bytes32 guess, uint targetBlock);

    constructor() payable {
        require(msg.value == 1 ether);
    }

    function lockInGuess(bytes32 hash) public payable {
        require(guesses[msg.sender].block == 0);
        require(msg.value == 1 ether);

        guesses[msg.sender].guess = hash;
        guesses[msg.sender].block  = block.number + 1;
        totalGames++;
        
        emit GuessLocked(msg.sender, hash, block.number + 1);
    }

    function settle() public {
        require(block.number > guesses[msg.sender].block);
        bytes32 answer = blockhash(guesses[msg.sender].block);

        guesses[msg.sender].block = 0;
        if (guesses[msg.sender].guess == answer) {
            totalWinners++;
            playerWins[msg.sender]++;
            payable(msg.sender).transfer(2 ether);
            emit GamePlayed(msg.sender, true, 2 ether);
        } else {
            emit GamePlayed(msg.sender, false, 0);
        }
    }
}