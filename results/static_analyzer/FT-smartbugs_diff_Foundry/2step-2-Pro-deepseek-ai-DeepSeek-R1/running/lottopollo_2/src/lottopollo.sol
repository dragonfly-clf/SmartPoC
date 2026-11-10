pragma solidity ^0.8.26;

contract lottopollo {
    address leader;
    uint timestamp;
    uint public totalDraws;
    uint public totalWinners;
    mapping(address => uint) public playerWins;
    
    event LotteryDraw(address indexed player, bool won, uint prize);
    event NewLeader(address indexed leader);
    
    function payOut(uint rand) internal {
        if (rand > 0 && block.timestamp - rand > 24 hours) {
            payable(msg.sender).send(msg.value);
            totalWinners++;
            playerWins[msg.sender]++;
            emit LotteryDraw(msg.sender, true, msg.value);
            
            if (address(this).balance > 0) {
                payable(leader).send(address(this).balance);
            }
        }
        else if (msg.value >= 1 ether) {
            leader = msg.sender;
            timestamp = rand;
            emit NewLeader(msg.sender);
        }
    }
    
    function randomGen() public view returns (uint randomNumber) {
        return block.timestamp;
    }
    
    function draw(uint seed) public {
        uint randomNumber = randomGen();
        totalDraws++;
        payOut(randomNumber);
        emit LotteryDraw(msg.sender, false, 0);
    }
    
    function getCurrentLeader() public view returns (address) {
        return leader;
    }
    
    function getPlayerStats(address player) public view returns (uint wins) {
        return playerWins[player];
    }
}