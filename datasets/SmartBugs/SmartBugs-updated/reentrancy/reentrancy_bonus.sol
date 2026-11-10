pragma solidity ^0.8.26;

contract Reentrancy_bonus{

    // INSECURE
    mapping (address => uint) private userBalances;
    mapping (address => bool) private claimedBonus;
    mapping (address => uint) private rewardsForA;
    
    uint public totalRewardsDistributed;
    uint public totalBonusClaims;
    mapping(address => uint) public userTotalRewards;

    function withdrawReward(address recipient) public {
        uint amountToWithdraw = rewardsForA[recipient];
        rewardsForA[recipient] = 0;
        (bool success, ) = payable(recipient).call{value: amountToWithdraw}("");
        require(success);
        userTotalRewards[recipient] += amountToWithdraw;
        totalRewardsDistributed += amountToWithdraw;
    }

    function getFirstWithdrawalBonus(address recipient) public {
        require(!claimedBonus[recipient]); // Each recipient should only be able to claim the bonus once

        unchecked {
            rewardsForA[recipient] += 100;
        }
        // <yes> <report> REENTRANCY
        withdrawReward(recipient); // At this point, the caller will be able to execute getFirstWithdrawalBonus again.
        claimedBonus[recipient] = true;
        totalBonusClaims++;
    }
    
    function depositFunds() external payable {
        userBalances[msg.sender] += msg.value;
    }
    
    function getUserBalance(address user) external view returns (uint) {
        return userBalances[user];
    }
}