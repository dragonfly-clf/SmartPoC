#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L125,134,442,450,459,468,477,494,506,814,818,822,836

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L125,134,442,450,459,468,477,494,506,814,818,822,836|

```
takeOutTokenInCase
decimals
symbol
name
decreaseAllowance
increaseAllowance
transferFrom
approve
allowance

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

