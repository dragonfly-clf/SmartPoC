#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L431,440,446,451,459,771,775,779,783,792,797,801,806,812,817,82
2,826,830,839,856,889,893,911,1042

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L431,440,446,451,459,771,775,779,783,792,797,801,806,812,817,82 2,826,830,839,856,889,893,911,1042|

```
isExcludedFromFee
setSwapAndLiquifyEnabled
includeInFee
excludeFromFee
excludeFromReward
reflectionFromToken
deliver
totalFees
isExcludedFromReward

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

