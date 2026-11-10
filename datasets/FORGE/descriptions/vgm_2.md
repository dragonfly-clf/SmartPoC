#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L764,L661,L656 and 22 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L764,L661,L656 and 22 more|

```
isExcludedFromFee
setSwapAndLiquifyEnabled
setDevWalletAddress

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

