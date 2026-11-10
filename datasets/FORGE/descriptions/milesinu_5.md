#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L713,714,709,715

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L713,714,709,715|


_decimals
_tTotal
_symbol
_name


##### Recommendation

Add the constant attribute to state variables that never change.


-----

