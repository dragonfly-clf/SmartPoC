#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L545

##### Description

The contract owner has the authority to stop tha sales for all users excluding the
owner. The owner may take advantage of it by setting the totalFee to zero and
transferring tokens to the contract address. As a result, the swapBack method will
revert since the totalFee is used as denominator.

|Criticality|critical|
|---|---|
|Location|contract.sol#L545|

```
function swapBack() internal swapping {
  uint256 dynamicLiquidityFee = isOverLiquified(targetLiquidity,
targetLiquidityDenominator) ? 0 : liquidityFee;
  uint256 amountToLiquify =
swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

