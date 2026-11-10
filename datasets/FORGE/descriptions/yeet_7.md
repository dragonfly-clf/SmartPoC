#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L473

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L473|

```
unitBalance = deltaBalance / (denominator - taxes.liquidity)

```

##### Recommendation

The multiplications should be prior to the divisions.