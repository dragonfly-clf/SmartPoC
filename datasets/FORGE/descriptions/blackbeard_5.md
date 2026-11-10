#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L366,364,365,367,373,207,220

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L366,364,365,367,373,207,220|

```
dividendsPerShareAccuracyFactor
WBNB
_totalSupply
ZERO
DOGE
DEAD

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

