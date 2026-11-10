#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L300

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L300|

```
feeAmount = amount.mul(totalFee).mul(multiplier).div(feeDenominator * 100)

```

##### Recommendation

The multiplications should be prior to the divisions.


-----

