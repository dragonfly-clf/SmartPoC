#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L442,451,457,462,470,792,796,800,804,813 and 14 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L442,451,457,462,470,792,796,800,804,813 and 14 more|

```
setSwapAndLiquifyEnabled
includeInFee
excludeFromFee
isExcludedFromFee
excludeFromReward
reflectionFromToken
deliver
totalFees
isExcludedFromReward

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

