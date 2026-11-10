#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L845,842,843,848,846,836,840,831,841,847,835,837,838,833

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L845,842,843,848,846,836,840,831,841,847,835,837,838,833|


swapThreshold
charityTaxBuy
liquidityTaxBuy
devTaxBuy
liquidityTaxWallet
marketingTaxSell
denominator
devTaxSell
marketingTaxBuy
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

