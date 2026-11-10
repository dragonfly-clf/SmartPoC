#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L83,88,214,222,226,245 and 27 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L83,88,214,222,226,245 and 27 more|

```
process
getAccountAtIndex
buyBackUpperLimitAmount

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

