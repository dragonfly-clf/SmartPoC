#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L743,730,738,1188,726

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L743,730,738,1188,726|

```
deadWallet
deadAddress
buybackFee

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

