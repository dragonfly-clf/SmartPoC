#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L429,438,750,754,758,762,771,776,780,785,791,796,801,805,809,8
18,835,869,873,893,1024

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L429,438,750,754,758,762,771,776,780,785,791,796,801,805,809,8 18,835,869,873,893,1024|

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

