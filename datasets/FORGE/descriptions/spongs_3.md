#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L2232,L2188,L2038 and 31 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L2232,L2188,L2038 and 31 more|

```
process
getAccountAtIndex
size

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

