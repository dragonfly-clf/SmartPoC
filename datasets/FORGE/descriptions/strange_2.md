#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L362,360,361,363,369,203,216

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L362,360,361,363,369,203,216|

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

