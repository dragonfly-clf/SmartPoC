#### L13 - Divide before Multiply Operation

**Criticality** minor

**Location** contract.sol#L623,741

##### Description

Performing divisions before multiplications may cause lose of prediction.

|Criticality|minor|
|---|---|
|Location|contract.sol#L623,741|

```
blockchainSupportBNB = BalanceBNB.div(100).mul(bsf)
marketingBNB = BalanceBNB.div(100).mul(mf)
productDevelopmentBNB = BalanceBNB.div(100).mul(pdf)
amount < balanceOf(uniswapV2Pair).div(10000).mul(pi2)
amount < balanceOf(uniswapV2Pair).div(10000).mul(pi1)

```

##### Recommendation

The multiplications should be prior to the divisions.