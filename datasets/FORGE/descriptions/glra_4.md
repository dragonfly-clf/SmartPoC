#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L838,843,848,831,835,840,845,837,842,847 and 4 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L838,843,848,831,835,840,845,837,842,847 and 4 more|

```
swapThreshold
marketingTaxWallet
marketingTaxSell
marketingTaxBuy
liquidityTaxWallet
liquidityTaxSell
liquidityTaxBuy
devTaxWallet
devTaxSell

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

