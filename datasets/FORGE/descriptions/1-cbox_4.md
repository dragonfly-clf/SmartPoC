#### CO - Code Optimization

**Criticality** minor

**Location** contract.sol#L654

##### Description

There are code segments that could be optimized. A segment may be optimized so
that it becomes a smaller size, consumes less memory, executes more rapidly, or
performs fewer operations.

The contract could initially calculate the corresponding index and access all the fees
with that.

|Criticality|minor|
|---|---|
|Location|contract.sol#L654|

```
uint256 _marketingFee = amount.mul(p2p ? marketingFee[2] : sell ?
marketingFee[1] : marketingFee[0]).div(10000);
       marketingFeeTotal = marketingFeeTotal.add(_marketingFee);
uint256 _liquidityFee = amount.mul(p2p ? liquidityFee[2] : sell ?
liquidityFee[1] : liquidityFee[0]).div(10000);
       liquidityFeeTotal = liquidityFeeTotal.add(_liquidityFee);
uint256 _developmentFee = amount.mul(p2p ? developmentFee[2] : sell ?
developmentFee[1] : developmentFee[0]).div(10000);
       developmentFeeTotal = developmentFeeTotal.add(_developmentFee);
uint256 _rewardsFee = amount.mul(p2p ? rewardsFee[2] : sell ? rewardsFee[1] :
rewardsFee[0]).div(10000);
       rewardsFeeTotal = rewardsFeeTotal.add(_rewardsFee);

```

##### Recommendation

Rewrite some code segments so the runtime will be more performant.


-----

