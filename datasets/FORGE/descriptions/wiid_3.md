#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L449,447,448,444

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L449,447,448,444|

```
_tTotal
_symbol
_name
_decimals

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

