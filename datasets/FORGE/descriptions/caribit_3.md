#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L1249,L1245

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1249,L1245|

```
deadWallet
buyBackUpperLimit

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

