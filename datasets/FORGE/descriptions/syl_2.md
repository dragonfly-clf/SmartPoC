#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L161,166,172,482,486,490,494,502,506,511,516,520,533,541,597,6
02,606,614,636,641

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L161,166,172,482,486,490,494,502,506,511,516,520,533,541,597,6 02,606,614,636,641|

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

Use the external attribute for functions never called from the contract.


-----

