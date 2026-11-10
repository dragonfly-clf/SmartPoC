#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L443,444,415,413,414,441,436,432,433,435 and 2 more

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L443,444,415,413,414,441,436,432,433,435 and 2 more|

```
swapEnabled
sstakeInsuranceFundFee
sellFee
operationalFee
liquidityFee
incineratorFee
feeDenominator
_symbol
_name

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

