#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L303,305,304,306,312,159,172

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L303,305,304,306,312,159,172|

```
dividendsPerShareAccuracyFactor
WBNB
_totalSupply
ZERO
DEAD
BUSD

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

