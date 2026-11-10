#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L387,394,417,392,393,389,402,403,401,418

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L387,394,417,392,393,389,402,403,401,418|

```
numTokensSellToAddToLiquidity
maxTaxFee
maxLiquidityFee
maxDevWalletFee
_tTotal
_symbol
_name
_maxTxAmount
_decimals

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

