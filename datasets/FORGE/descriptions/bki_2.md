#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L536,545,704,708,712,716,725,735,744,753 and 4 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L536,545,704,708,712,716,725,735,744,753 and 4 more|

```
reflectionFromToken
isExcluded
decreaseAllowance
increaseAllowance
transferFrom
approve
allowance
transfer
totalSupply

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

