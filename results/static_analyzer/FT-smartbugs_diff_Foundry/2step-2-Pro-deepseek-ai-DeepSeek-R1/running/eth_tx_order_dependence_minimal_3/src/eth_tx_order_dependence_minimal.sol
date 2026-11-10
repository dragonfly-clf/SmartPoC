pragma solidity ^0.8.26;

contract EthTxOrderDependenceMinimal {
    address public owner;
    bool public claimed;
    uint public reward;
    uint public totalClaims;
    uint public totalRewardsDistributed;
    mapping(address => uint) public userClaims;

    event RewardSet(uint amount, address setter);
    event RewardClaimed(address claimer, uint amount, uint submission);

    constructor() {
        owner = msg.sender;
    }

    function setReward() public payable {
        require(!claimed);
        require(msg.sender == owner);
        payable(owner).transfer(reward);
        reward = msg.value;
        emit RewardSet(msg.value, msg.sender);
    }

    function claimReward(uint256 submission) public {
        require(!claimed);
        require(submission < 10);
        payable(msg.sender).transfer(reward);
        claimed = true;
        totalClaims++;
        totalRewardsDistributed += reward;
        userClaims[msg.sender]++;
        emit RewardClaimed(msg.sender, reward, submission);
    }

    function getContractBalance() public view returns (uint) {
        return address(this).balance;
    }
}