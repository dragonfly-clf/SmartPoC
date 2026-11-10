#### ZD - Zero Division

**Criticality** critical

**Location** contract.sol#L638

##### Description

The contract is using variables that may be set to zero as denominators. As a result,
the transactions will revert.

The variable totalFee can be set to zero.

|Criticality|critical|
|---|---|
|Location|contract.sol#L638|


function swapBack() internal swapping {

uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity, targetLiquidityDenominator) ?
0 : liquidityFee;

uint256 amountToLiquify = swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);


##### Recommendation

The contract should prevent those variables to be set to zero or should not allow to
execute the corresponding statements.


-----

