#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L165,170,176,471,475,479,483,491,495,500 and 11 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L165,170,176,471,475,479,483,491,495,500 and 11 more|

```
transferFrom
transfer
changeRouterVersion
rescueToken
getCirculatingSupply
setSwapAndLiquifyByLimitOnly
setSwapAndLiquifyEnabled
setIsExcludedFromFee
setMarketPairStatus

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

