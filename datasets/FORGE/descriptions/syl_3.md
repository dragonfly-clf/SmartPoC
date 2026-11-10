#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L142,141,385,383,384

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L142,141,385,383,384|

```
_symbol
_name
_decimals
asdasd
_lockTime

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

