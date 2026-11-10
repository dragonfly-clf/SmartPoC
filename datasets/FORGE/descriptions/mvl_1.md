#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L165,173,1079,1083,1087,1091,1100,1109,1118,1127,1144,1157,11
73,1177,1181,1193,1221,1268,1272,1292,1466

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L165,173,1079,1083,1087,1091,1100,1109,1118,1127,1144,1157,11 73,1177,1181,1193,1221,1268,1272,1292,1466|

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

