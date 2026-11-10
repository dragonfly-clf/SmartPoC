#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L384,385,397,395,396,399,398,407

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L384,385,397,395,396,399,398,407|

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

