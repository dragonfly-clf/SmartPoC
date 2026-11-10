#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L1209,1202

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1209,1202|

```
enableAntiBot
deadWallet

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

