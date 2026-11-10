#### 4.3.3.3 Repeatable call risk

###### If Owner call setupVestors function multiple times, there will be duplicate vestors in the vestor

 31


-----

###### array.When the setupVestors is called multiple times, if the vestor calls withdrawRewardPV

 intentionally or unintentionally during the calling process, initRewardPV and insurVestingTotalPV may

 get unexpected values.

 If setupVestors can be called multiple times, then when the owner is called, the vestor also calls

 withdrawRewardPV. In this case, the gas price of calling withdrawRewardPV is higher than that of

 calling setupVestors. Will execute withdrawRewardPV first, and then execute setupVestors, the data

 will appear unexpected. Competitive conditions similar to approve.

  contracts/fixedvesting/FixedVesting.sol


**function setupVestors(**


address[] memory _vestors,


uint256[] memory _vestingRewardPV,


uint256[] memory _initRewardPV


) external onlyOwner {


require(_vestors.length == _vestingRewardPV.length, "AV:1");


require(_initRewardPV.length == _vestingRewardPV.length, "AV:2");


**for (uint256 i = 0; i < _vestors.length; i++) {**


address vestor = _vestors[i];


vestors.push(vestor);


initRewardPV[vestor] = _initRewardPV[i];


insurVestingTotalPV[vestor] = _vestingRewardPV[i];


}


}


###### Fix Status: This issue has been fixed.

