#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L436,445,451,456,464,777,781,785,789,798 and 21 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L436,445,451,456,464,777,781,785,789,798 and 21 more|

```
isIncludedFromFee
isExcludedFromFee
releasePrivateSalecoinStatusUpdate
setSwapAndLiquifyEnabled
includeInFee
excludeFromFee
excludeFromReward
reflectionFromToken
deliver

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

