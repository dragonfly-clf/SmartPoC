#### L01 - Public Function could be Declared External

**Criticality** minor

**Location** contract.sol#L531,539,556,570,582,605,627,650,670,874,889,949,957,1004

##### Description

Public functions that are never called by the contract should be declared external to
save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L531,539,556,570,582,605,627,650,670,874,889,949,957,1004|

```
mint
transferOwnership
renounceOwnership
burnFrom
burn
decreaseAllowance
increaseAllowance
transferFrom
approve

```
...


##### Recommendation

Use the external attribute for functions never called from the contract.


-----

