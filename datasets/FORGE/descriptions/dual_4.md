#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L1015,1012,1014,1002,986,1024,714

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1015,1012,1014,1002,986,1024,714|

```
_rewardTokenAddress
transfertoWalletFee
rewardToken
externalFee
deadWallet
_externalwallet
ZeroWallet

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

