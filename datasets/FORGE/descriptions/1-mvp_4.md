#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L160,165,171,494,498,502,506,514,518,523,528,532,545,553,609,6
14,618,626,648,653

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L160,165,171,494,498,502,506,514,518,523,528,532,545,553,609,6 14,618,626,648,653|

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

