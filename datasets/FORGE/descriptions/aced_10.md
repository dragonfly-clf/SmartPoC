#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L1242

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1242|

```
fees = fees.div(100).mul(sellFeeIncreaseFactor)

```

##### Recommendation

The multiplications should be prior to the divisions.


-----

