#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L145,146,147

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L145,146,147|


_decimals
_symbol
_name


##### Recommendation

Add the constant attribute to state variables that never change.


-----

