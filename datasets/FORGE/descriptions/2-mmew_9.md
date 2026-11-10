#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L1149

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1149|

```
marketingBNB = receivedBNB.div(7).mul(4)

```

##### Recommendation

The multiplications should be prior to the divisions.