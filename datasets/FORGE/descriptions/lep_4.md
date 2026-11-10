#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L815,826,812,843,838

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L815,826,812,843,838|

```
owe
ererer
deadWallet
backFee
USDT

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

