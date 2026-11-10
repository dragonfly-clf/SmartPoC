#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L603,594,596,601,595,602

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L603,594,596,601,595,602|

```
_symbol
_numTokensSellToAddToLiquidity
_name
_maxWalletToken
_maxTxAmount
_decimals

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

