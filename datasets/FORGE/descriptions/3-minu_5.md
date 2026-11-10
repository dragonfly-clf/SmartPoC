#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L716,714,715,739,740,728

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L716,714,715,739,740,728|

```
numTokensSellToAddToLiquidity
marketing_address
_timeLimit
_symbol
_name
_decimals

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

