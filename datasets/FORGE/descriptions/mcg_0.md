#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L1960,2014

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the
```
maxSellTransactionAmount to a low value like 1. This will essentially prevent the

```
users from selling.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1960,2014|

```
if (
  maxSellTransactionAmount != 0 &&
  isSelling && // sells only by detecting transfer to automated market maker
pair
  from != address(uniswapV2Router) //router -> pair is removing liquidity
which shouldn't have max
) {
  require(
    amount <= maxSellTransactionAmount,
    "maxSellTransactionAmount."
  );
}

```

The contract owner has the authority to tax only the sales with an additional 50%
fee. The owner may take advantage of it by setting the MCGRewardsSellFee to 50.

```
if (isSelling) {
  MCGRewardsFee = MCGRewardsSellFee;
} else if(to == stakingAddress) {
  MCGRewardsFee = 0;
  operationsFees = 0;
} else {
  MCGRewardsFee = MCGRewardsBuyFee;
}
uint256 totalFees = MCGRewardsFee.add(liquidityFee).add(operationsFees);

```

##### Recommendation


-----

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

