#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L207,220,366,364,365,367,373

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L207,220,366,364,365,367,373|

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

