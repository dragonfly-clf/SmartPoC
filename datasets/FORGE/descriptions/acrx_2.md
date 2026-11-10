#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L1065,L927,L909 and 21 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1065,L927,L909 and 21 more|

```
isExcludedFromFee
setSwapAndLiquifyEnabled
includeInFee

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

