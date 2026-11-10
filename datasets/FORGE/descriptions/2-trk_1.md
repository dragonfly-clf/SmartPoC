#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L82,90,283,291,315,322,334,357,379,402 and 1 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L82,90,283,291,315,322,334,357,379,402 and 1 more|

```
decreaseAllowance
increaseAllowance
transferFrom
approve
transfer
balanceOf
totalSupply
symbol
name

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

