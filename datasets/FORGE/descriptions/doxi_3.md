#### L02 - State Variables could be Declared Constant

**Criticality** minor / informative

**Location** contract.sol#L470,469,467,466,468,465

**Status** Unresolved

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L470,469,467,466,468,465|
|Status|Unresolved|

```
_saleCharityFee
_saleMarketingFee
_saleReserveFee
_saleLiquidityFee
_saleDevFee
_saleTaxFee

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

