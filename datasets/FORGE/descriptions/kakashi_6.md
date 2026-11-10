#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L701,720,699,700,695,718

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L701,720,699,700,695,718|

```
numTokensSellToAddToLiquidity
_tTotal
_symbol
_name
_lpWallet
_decimals

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

