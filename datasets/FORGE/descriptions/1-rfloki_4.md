#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L833,L846,L841 and 11 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L833,L846,L841 and 11 more|

```
swapThreshold
marketingTaxWallet
marketingTaxSell

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

