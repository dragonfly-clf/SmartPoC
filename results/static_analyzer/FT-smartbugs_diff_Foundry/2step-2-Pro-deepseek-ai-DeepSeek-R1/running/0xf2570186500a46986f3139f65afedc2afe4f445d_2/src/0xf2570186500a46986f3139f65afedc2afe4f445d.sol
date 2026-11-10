pragma solidity ^0.8.26;

contract RealOldFuckMaker {
    address fuck = 0xc63e7b1DEcE63A77eD7E4Aeef5efb3b05C81438D;
    uint256 public totalFucksMade;
    uint256 public totalRewards;
    mapping(address => uint256) public userFucks;
    
    event FuckMade(address indexed user, uint32 count, uint256 timestamp);
    event RewardClaimed(address indexed user, uint256 amount);
    
    function makeOldFucks(uint32 number) public {
        uint32 i;
        for (i = 0; i < number; i++) {
            (bool success, ) = fuck.call(abi.encodeWithSignature("giveBlockReward()"));
            if (success) {
                totalRewards++;
            }
        }
        totalFucksMade += number;
        userFucks[msg.sender] += number;
        emit FuckMade(msg.sender, number, block.timestamp);
    }
    
    function claimRewards() public {
        uint256 userRewards = userFucks[msg.sender];
        require(userRewards > 0, "No rewards to claim");
        
        userFucks[msg.sender] = 0;
        emit RewardClaimed(msg.sender, userRewards);
    }
    
    function getUserStats(address user) public view returns (uint256 fucksMade, uint256 rewards) {
        fucksMade = userFucks[user];
        rewards = userFucks[user];
    }
}