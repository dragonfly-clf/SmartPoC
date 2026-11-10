#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L213,219,227,235,514,518,522,526,535,540 and 15 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L213,219,227,235,514,518,522,526,535,540 and 15 more|

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

