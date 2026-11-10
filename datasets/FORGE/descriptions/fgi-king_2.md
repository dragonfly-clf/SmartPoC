#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L186,191,197,201,205,212,523,527,531,535,543,547,552,557,561,57
4,582,638,643,647,655,677,682

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L186,191,197,201,205,212,523,527,531,535,543,547,552,557,561,57 4,582,638,643,647,655,677,682|

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

