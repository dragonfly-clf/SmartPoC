#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L575

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L575|

```
liquidityHalf = tokenToLiquidity.div(2)

```

##### Recommendation

The multiplications should be prior to the divisions.