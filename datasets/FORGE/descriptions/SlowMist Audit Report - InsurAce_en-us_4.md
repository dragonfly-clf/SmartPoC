#### 4.3.2.1 DoS issue

###### _getDelAccuRwAmtPS has 3 while loop nestings, which will be affected by the parameters of

 lastScheduleCounter, gRewardTokenRatePerStakedTokenArray, _unstakeLockArrayBlockPerStaker,

 and dos due to more users or more mining cycles added.

  contracts/staking/ScheduledMiningProgram.sol


**function _getDelAccuRwAmtPS(**


uint256 _lastCalculatedBlockPerStaker,


uint256 _stakedAmtPerStaker,


uint256[] memory _unstakeLockArrayBlockPerStaker,


uint256[] memory _unstakeLockArrayAmtPerStaker


###### 26


-----

) private view returns (uint256) {


console.log("getDeltaAccumulativeRewardAmtPerStaker++");


console.log(_lastCalculatedBlockPerStaker);


console.log(_stakedAmtPerStaker);


console.log(_unstakeLockArrayBlockPerStaker.length);


uint256 retV = 0;


// go thru the list of all schedules


uint256 scheduleIndex = lastScheduleCounter;


**while (scheduleIndex >= 1) {**


**if (_lastCalculatedBlockPerStaker >= endMiningBlockPerSchedule[scheduleIndex]) {**


**break;**


}


// narrow down block delta


uint256 minWall = Math.max(_lastCalculatedBlockPerStaker, startMiningBlockPerSchedule[scheduleIndex]);


uint256 maxWall = Math.min(block.number, endMiningBlockPerSchedule[scheduleIndex]);


console.log("minWall: ", minWall);

console.log("maxWall: ", maxWall);


**if (minWall >= maxWall) {**


scheduleIndex = scheduleIndex.sub(1);


**continue;**


}


uint256 rateChangeIndex = gRewardTokenRatePerStakedTokenArray.length;


**if (rateChangeIndex == 0) {**


**break;**


}


uint256 rewardAccumulatedBetweenWalls = 0;


**while (rateChangeIndex > 0) {**


uint256 blockNumber = gRewardTokenRatePerStakedTokenArray[rateChangeIndex - 1];


console.log("blockNumber: ", blockNumber);


**if (blockNumber >= maxWall) {**


rateChangeIndex = rateChangeIndex.sub(1);


**continue;**


}


**if (blockNumber >= minWall) {**


uint256 delta = _getDeltaAccumulativeRewardsWithFixRatePerStaker(blockNumber, maxWall,


gRewardTokenRatePerStakedTokenMap[blockNumber], _stakedAmtPerStaker, _unstakeLockArrayBlockPerStaker,


_unstakeLockArrayAmtPerStaker);


rewardAccumulatedBetweenWalls = delta.add(rewardAccumulatedBetweenWalls);


maxWall = blockNumber;


rateChangeIndex = rateChangeIndex.sub(1);


**continue;**


###### 27


-----

}


**if (blockNumber < minWall) {**


uint256 delta = _getDeltaAccumulativeRewardsWithFixRatePerStaker(minWall, maxWall,


gRewardTokenRatePerStakedTokenMap[blockNumber], _stakedAmtPerStaker, _unstakeLockArrayBlockPerStaker,


_unstakeLockArrayAmtPerStaker);


rewardAccumulatedBetweenWalls = delta.add(rewardAccumulatedBetweenWalls);


**break;**


}


}


retV = rewardAccumulatedBetweenWalls.add(retV);


scheduleIndex = scheduleIndex.sub(1);


}


**return retV;**


}


###### Fix Status: This issue has been fixed，

