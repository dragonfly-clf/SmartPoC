#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L209,215,223,231,509,513,517,521,530,535 and 15 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L209,215,223,231,509,513,517,521,530,535 and 15 more|

```
isExcludedFromFee
setSwapAndLiquifyEnabled
setDevWalletAddress
setMaxTxPercent
includeInFee
excludeFromFee
excludeFromReward
reflectionFromToken
deliver

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

