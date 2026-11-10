#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L561

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L561|

```
amountBNBLiquidity =
amountBNB.mul(dynamicLiquidityFee.div(2)).div(totalFeeShare.sub(dynamicLiquidi
tyFee.div(2)))
amountToLiquify =
swapThreshold.mul(dynamicLiquidityFee.div(2)).div(totalFeeShare)

```

##### Recommendation

The multiplications should be prior to the divisions.