#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L83,91,115,134,142,153,171,193,212,356,360

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L83,91,115,134,142,153,171,193,212,356,360|

```
transferOwnership
renounceOwnership
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

