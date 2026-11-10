#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L174,180,186,191,199,492,496,500,504,513 and 13 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L174,180,186,191,199,492,496,500,504,513 and 13 more|

```
isExcludedFromFee
setSwapAndLiquifyEnabled
includeInFee
excludeFromFee
excludeFromReward
reflectionFromToken
totalFees
isExcludedFromReward
decreaseAllowance

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

