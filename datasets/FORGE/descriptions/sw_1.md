#### L02 - State Variables could be Declared Constant

**Criticality** minor / informative

**Location** contract.sol#L492,496,505,507,498,497

**Status** Unresolved

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L492,496,505,507,498,497|
|Status|Unresolved|


_tTotal
_name
burnAdd
_max_tx_size
_decimals
_symbol


##### Recommendation

Add the constant attribute to state variables that never change.

