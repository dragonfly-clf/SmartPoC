#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L497,L484,L465 and 2 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L497,L484,L465 and 2 more|

```
mint
decreaseAllowance
increaseAllowance

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

