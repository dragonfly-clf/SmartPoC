#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L443,441,442,437,457

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L443,441,442,437,457|

```
numTokensSellToAddToLiquidity
_tTotal
_symbol
_name
_decimals

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

