#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L807,816,806,814,815,835

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L807,816,806,814,815,835|

```
numTokensSellToAddToLiquidity
_symbol
_name
_developerWalletAddress
_decimals
_charityAddress

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

