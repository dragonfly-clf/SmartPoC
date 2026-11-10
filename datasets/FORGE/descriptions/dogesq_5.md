#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L589,563,561,562

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L589,563,561,562|


_symbol
_name
_decimals
BurnAddress


##### Recommendation

Add the constant attribute to state variables that never change.


-----

