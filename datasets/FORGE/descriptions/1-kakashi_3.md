#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L533,503,501,502,497

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L533,503,501,502,497|


_tTotal
_symbol
_name
_decimals
BUSD


##### Recommendation

Add the constant attribute to state variables that never change.


-----

