#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L439,440,436,438,291,446,278

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L439,440,436,438,291,446,278|


WBNB
_totalSupply
dividendsPerShareAccuracyFactor
DEAD
BUSD
DEAD_NON_CHECKSUM
ZERO


##### Recommendation

Add the constant attribute to state variables that never change.


-----

