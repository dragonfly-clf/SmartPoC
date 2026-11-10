#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L459,516,457,458,453

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L459,516,457,458,453|

```
_tTotal
_symbol
_name
_isEnabledBuyBackAndBurn
_decimals

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

