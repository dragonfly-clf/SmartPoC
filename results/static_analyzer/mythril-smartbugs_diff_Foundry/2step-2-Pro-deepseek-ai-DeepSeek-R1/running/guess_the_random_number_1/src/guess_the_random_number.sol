pragma solidity ^0.8.26;

contract GuessTheRandomNumberChallenge {
    uint8 answer;
    address public owner;
    uint public totalGames;
    uint public totalWins;
    mapping(address => uint) public playerWins;
    
    event GamePlayed(address indexed player, uint8 guess, bool won, uint prize);
    event NewGameStarted(address indexed starter, uint8 newAnswer);

    constructor() payable {
        require(msg.value == 1 ether);
        answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));
        owner = msg.sender;
        emit NewGameStarted(msg.sender, answer);
    }

    function isComplete() public view returns (bool) {
        return address(this).balance == 0;
    }

    function guess(uint8 n) public payable {
        require(msg.value == 1 ether);
        totalGames++;

        if (n == answer) {
            payable(msg.sender).transfer(2 ether);
            totalWins++;
            playerWins[msg.sender]++;
            emit GamePlayed(msg.sender, n, true, 2 ether);
        } else {
            emit GamePlayed(msg.sender, n, false, 0);
        }
    }

    function restartGame() public payable {
        require(msg.value == 1 ether, "Must send 1 ETH to restart");
        answer = uint8(uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), block.timestamp))));
        emit NewGameStarted(msg.sender, answer);
    }
}