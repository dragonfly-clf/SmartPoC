#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L598,597,599,605

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L598,597,599,605|

```
_totalSupply
ZERO
WBNB
DEAD

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

