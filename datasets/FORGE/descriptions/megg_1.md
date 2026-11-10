#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L83,92,619,626,633,652,660,671,688,714,733,750,862

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L83,92,619,626,633,652,660,671,688,714,733,750,862|

```
mint
decreaseAllowance
increaseAllowance
transferFrom
approve
allowance
transfer
totalSupply
symbol

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

