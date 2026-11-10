#### ZD - Zero Division

**Criticality** critical

**Location** contract.sol#L1239

**Status** Unresolved

##### Description

The contract is using variables that may be set to zero as denominators. As a result,
the transactions will revert. TotalTax has a fixed value of 5. The sum of BurnFee and
ReflectionFee can be 5 so the result of the operation will be zero.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1239|
|Status|Unresolved|

```
uint256 denominator = (TotalTax.sub(BurnFee).sub(ReflectionFee)).mul(2);

```

##### Recommendation

The contract should prevent those variables to be set to zero or should not allow to
execute the corresponding statements.


-----

