pragma solidity ^0.8.26;

contract FindThisHash {
    bytes32 constant public hash = 0xb5b5b97fafd9855eec9b41f74dfb6c38f5951141f9a3ecd7f44d5479b630ee0a;
    uint public totalAttempts;
    uint public totalWinners;
    mapping(address => uint) public playerAttempts;
    mapping(address => bool) public hasWon;
    
    event HashAttempt(address indexed player, string attempt, bool successful);
    event PrizeClaimed(address indexed winner, uint prize);

    constructor() payable {}

    function solve(string calldata solution) public {
        require(hash == sha256(bytes(solution)));
        payable(msg.sender).transfer(1000 ether);
        
        totalWinners++;
        hasWon[msg.sender] = true;
        emit PrizeClaimed(msg.sender, 1000 ether);
    }

    function attemptHash(string calldata guess) external {
        totalAttempts++;
        playerAttempts[msg.sender]++;
        
        bool correct = hash == sha256(bytes(guess));
        emit HashAttempt(msg.sender, guess, correct);
        
        if (correct) {
            solve(guess);
        }
    }

    function getPlayerStats(address player) external view returns (uint attempts, bool winner) {
        return (playerAttempts[player], hasWon[player]);
    }
}