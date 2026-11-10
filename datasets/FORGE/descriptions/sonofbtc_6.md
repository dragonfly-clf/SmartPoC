#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L543

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L543|

```
feeAmount = amount.div(100).mul(99)

```

##### Recommendation

The multiplications should be prior to the divisions.