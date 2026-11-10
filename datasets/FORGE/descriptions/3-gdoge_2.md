#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L203,216,362,360,361,363,369

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L203,216,362,360,361,363,369|

```
_totalSupply
ZERO
WBNB
DOGE
DEAD
dividendsPerShareAccuracyFactor

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

