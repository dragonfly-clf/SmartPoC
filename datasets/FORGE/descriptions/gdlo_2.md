#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L622,L535,L518 and 18 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L622,L535,L518 and 18 more|

```
isExcludedFromFee
setSwapAndLiquifyEnabled
includeInFee

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

