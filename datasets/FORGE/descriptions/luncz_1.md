#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L180,184,432,449,452,455,458,465,469,473,477,482,486,490,493,5
34,542,693

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L180,184,432,449,452,455,458,465,469,473,477,482,486,490,493,5 34,542,693|

```
isExcludedFromFee
reflectionFromToken
deliver
totalFees
isExcludedFromReward
decreaseAllowance
increaseAllowance
transferFrom
approve

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

