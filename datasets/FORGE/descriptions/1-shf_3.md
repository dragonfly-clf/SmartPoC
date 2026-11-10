#### ZD - Zero Division

**Criticality** critical

**Location** contract.sol#L376

**Status** Unresolved

##### Description

The contract is using variables that may be set to zero as denominators. As a result,
the transactions will revert.

The variables totalETHFee can be set to zero if the totalFee is equal to burnFee.

|Criticality|critical|
|---|---|
|Location|contract.sol#L376|
|Status|Unresolved|


function swapBack() internal swapping {

uint256 totalETHFee = totalFee - burnFee;

uint256 amountToLiquify = (swapThreshold * liquidityFee)/(totalETHFee * 2);


##### Recommendation

The contract could embody a check to avoid the totalFee and burnFee equality.

The contract should prevent those variables to be set to zero or should not allow to
execute the corresponding statements.


-----

