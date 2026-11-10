#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L887,L879,L875 and 14 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L887,L879,L875 and 14 more|

```
setSwapAndLiquifyEnabled
isExcludedFromMaxWallet
isExcludedFromFee

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

