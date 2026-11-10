#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L169,174,180,184,188,195,506,510,514,518 and 13 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L169,174,180,184,188,195,506,510,514,518 and 13 more|

```
transferFrom
transfer
changeRouterVersion
getCirculatingSupply
setSwapAndLiquifyByLimitOnly
setSwapAndLiquifyEnabled
setIsExcludedFromFee
setMarketPairStatus
approve

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

