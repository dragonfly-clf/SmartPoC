#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L1008,1007,1006

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1008,1007,1006|

```
walletPresale
walletLiquidity
walletIDO

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

