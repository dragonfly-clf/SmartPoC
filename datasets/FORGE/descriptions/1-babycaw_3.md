#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L468,466,467,1011,446

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L468,466,467,1011,446|

```
deadWallet
deadAddress
_symbol
_name
_decimals

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

