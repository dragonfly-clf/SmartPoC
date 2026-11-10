#### L02 - State Variables could be Declared Constant

**Criticality** minor

**Location** contract.sol#L624,611,601,622,609,603,602,604,371,600,612

##### Description

Constant state variables should be declared constant to save gas.

|Criticality|minor|
|---|---|
|Location|contract.sol#L624,611,601,622,609,603,602,604,371,600,612|

```
ZERO
liquidityFee
dividendsPerShareAccuracyFactor
autofirePitFee
safuDividendFee
sellFee
feeDenominator
swapEnabled
treasuryFee

```
...


##### Recommendation

Add the constant attribute to state variables that never change.


-----

