#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L385,386,398,396,397,400,399,408

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L385,386,398,396,397,400,399,408|

```
maxPossibleFee
_tTotal
_tFeeTotal
_symbol
_name
_decimals
Wallet_zero
Wallet_Burn

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

