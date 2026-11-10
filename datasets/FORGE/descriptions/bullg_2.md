#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L332,341,632,636,640,644,652,657,661,665 and 6 more

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L332,341,632,636,640,644,652,657,661,665 and 6 more|

```
reflectionFromToken
reflect
totalFees
decreaseAllowance
increaseAllowance
transferFrom
approve
allowance
excludeFromFee

```
...


##### Recommendation

Use the external attribute for functions never called from the contract


-----

