#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L161,166,172,479,483,487,491,499,503,508 and 11 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L161,166,172,479,483,487,491,499,503,508 and 11 more|


transferFrom
transfer
changeRouterVersion
getCirculatingSupply
setSwapAndLiquifyByLimitOnly
setSwapAndLiquifyEnabled
setIsExcludedFromFee
setMarketPairStatus
rescueToken
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

