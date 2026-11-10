#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L161,166,172,483,487,491,495,503,507,512,517,521,534,542,598,60
3,607,615,637,642

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L161,166,172,483,487,491,495,503,507,512,517,521,534,542,598,60 3,607,615,637,642|

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

