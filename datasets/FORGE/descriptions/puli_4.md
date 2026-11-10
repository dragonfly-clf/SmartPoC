#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L829,L828,L830

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L829,L828,L830|

```
_symbol
_name
_decimals

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

