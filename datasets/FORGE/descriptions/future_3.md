#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L385,383,384,142,141

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L385,383,384,142,141|

```
asdasd
_lockTime
_symbol
_name
_decimals

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

