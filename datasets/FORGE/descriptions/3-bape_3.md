#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L689,690,701,700,723,533

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L689,690,701,700,723,533|

```
dividendsPerShareAccuracyFactor
tradingStatus
launchedAt
hldFee
ZERO
DEAD

```

##### Recommendation

Add the constant attribute to state variables that never change.


-----

