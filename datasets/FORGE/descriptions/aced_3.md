#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L215,887,892,855,883,858

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L215,887,892,855,883,858|

```
tradingIsEnabled
previousBuybackFee
deadAddress
_busdDividendRewardsFeeSell
_busdDividendRewardsFeeBuy
lastAmount

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

