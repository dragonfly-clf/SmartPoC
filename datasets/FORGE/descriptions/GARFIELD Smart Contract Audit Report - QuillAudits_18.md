16. Comparison to boolean constants

 Line Code

 1384-1385 _isExcludedFromMaxTx[from] == false && // default will be false  _isExcludedFromMaxTx[to] == false // default will be false

 Description Boolean constants of the _isExcludedFromMaxTx[from] and _isExcludedFromMaxTx[to] can be used directly and do not need to be compared to true or false.

 Remediation We recommend removing the equality to the boolean constant.

 Status: Closed The Garfield team made some fixes based on our recommendations. We address below the fixes introduced up to commit 4c9bfa4e6c11925718f3a69ede4b5f31d0744ffd

 0516


-----

|Typo|Col2|
|---|---|
|Line|Code|
|936|uint256 tokensIntoLiqudity|

|Line|Code|
|---|---|
|1291,1292, rewardCycleBlock = 7 days; easyRewardCycleBlock = 1 days; 1295, 1300 disruptiveCoverageFee = 2 ether; winningDoubleRewardPercentage = 5;||


#### 