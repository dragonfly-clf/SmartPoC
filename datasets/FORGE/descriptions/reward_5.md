#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L450,451,420,418,419,462

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L450,451,420,418,419,462|

```
swapEnabled
_symbol
_name
_decimals
ZERO
DEAD

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

