#### ZD - Zero Division

**Criticality** critical

**Location** contract.sol#L374

**Status** Unresolved

##### Description

The contract is using variables that may be set to zero as denominators. This may
happen by setting the totalFee to zero or by setting the totalFee to equal the
burnFee. As a result, the transactions will revert. This functionality is triggered during
a sale or transfer transaction. Hence, the contract may prevent the users from
selling.

|Criticality|critical|
|---|---|
|Location|contract.sol#L374|
|Status|Unresolved|

```
uint256 totalETHFee = totalFee - burnFee;
uint256 amountToLiquify = (swapThreshold * liquidityFee)/(totalETHFee * 2);

```

##### Recommendation

The contract should prevent those variables to be set to zero or should not allow to
execute the corresponding statements.


-----

