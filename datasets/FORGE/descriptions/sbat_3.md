#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L566,575,850,883,887,891,895,904,909,913,918,924,929,934,938,94
2,951,968,1003,1007,1033,1162

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L566,575,850,883,887,891,895,904,909,913,918,924,929,934,938,94 2,951,968,1003,1007,1033,1162|

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

