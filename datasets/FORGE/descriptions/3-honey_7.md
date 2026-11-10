#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L574

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L574|

```
unitBalance = deltaBalance / (denominator - temp.liquidity)

```

##### Recommendation

The multiplications should be prior to the divisions.