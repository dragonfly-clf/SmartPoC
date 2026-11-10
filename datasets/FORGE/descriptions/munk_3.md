#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L256,269,414,416,418,417,424

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L256,269,414,416,418,417,424|

```
_totalSupply
ZERO
DEAD_NON_CHECKSUM
DEAD
BUSD
dividendsPerShareAccuracyFactor

```

-----

```
WBNB

```

##### Recommendation

Add the constant attribute to state variables that never change.

