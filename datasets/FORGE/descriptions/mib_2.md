#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L161,166,172,481,485,489,493,501,505,510 and 10 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L161,166,172,481,485,489,493,501,505,510 and 10 more|


transferFrom
transfer
changeRouterVersion
getCirculatingSupply
setSwapAndLiquifyByLimitOnly
setSwapAndLiquifyEnabled
setIsExcludedFromFee
setMarketPairStatus
approve
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

