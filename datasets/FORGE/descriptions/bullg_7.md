#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L821

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L821|

```
tLiquidity = tAmount.div(10 ** 2).mul(_liquidityFee)
tFee = tAmount.div(10 ** 2).mul(_taxFee)

```

##### Recommendation

The multiplications should be prior to the divisions.