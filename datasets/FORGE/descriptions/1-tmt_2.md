#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L167,171,417,420,423,426,433,437,440,444 and 11 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L167,171,417,420,423,426,433,437,440,444 and 11 more|

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

