#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L779,788,786,787,782,803

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L779,788,786,787,782,803|

```
numTokensSellToAddToLiquidity
_tTotal
_symbol
_name
_decimals
_DevMarketingWalletAddress

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

