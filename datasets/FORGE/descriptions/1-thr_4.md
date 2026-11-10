#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L381,374,379,380,376,394

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L381,374,379,380,376,394|

```
numTokensSellToAddToLiquidity
_tTotal
_symbol
_name
_developmentWalletAddress
_decimals

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

