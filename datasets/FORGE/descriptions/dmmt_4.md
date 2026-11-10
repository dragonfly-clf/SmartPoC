#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L925,909,915,914,913

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L925,909,915,914,913|


_name
_symbol
_decimals
_tTotal
deadAddress


##### Recommendation

Add the constant attribute to state variables that never change.


-----

