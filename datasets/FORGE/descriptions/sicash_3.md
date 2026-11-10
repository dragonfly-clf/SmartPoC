#### L02 - State Variables could be Declared Constant

**Criticality** minor / informative

**Location** contract.sol#L307,563,561,557,308,562

**Status** Unresolved

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L307,563,561,557,308,562|
|Status|Unresolved|

```
_previousOwner
_decimals
_name
_tTotal
_lockTime
_symbol

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

