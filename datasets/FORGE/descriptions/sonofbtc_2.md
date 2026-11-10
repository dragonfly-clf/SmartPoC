#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L204,217,363,365,364,366 and 2 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L204,217,363,365,364,366 and 2 more|

```
deadBlocks
_totalSupply
ZERO

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

