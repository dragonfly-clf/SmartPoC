#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L159,164,170,462,466,470,474,482,486,491 and 10 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L159,164,170,462,466,470,474,482,486,491 and 10 more|

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

