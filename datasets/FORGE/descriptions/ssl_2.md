#### ZD - Zero Division

**Criticality** critical

**Location** contract.sol#L334

**Status** Unresolved

##### Description

The contract is using variables that may be set to zero as denominators. As a result,
the transactions will revert.

The variable totalFee can be set to zero and provoke zero division. As a result the
transfer transaction will be reverted.

|Criticality|critical|
|---|---|
|Location|contract.sol#L334|
|Status|Unresolved|


function _transferFrom(address sender, address recipient, uint256 amount) internal returns (bool)
{

//..
if(shouldSwapBack()){ swapBack(); }

function swapBack() internal swapping {

uint256 totalBNBFee = totalFee;

uint256 amountToLiquify = (swapThreshold * liquidityFee)/(totalBNBFee * 2);


##### Recommendation

The contract should prevent those variables to be set to zero or should not allow to
execute the corresponding statements.


-----

