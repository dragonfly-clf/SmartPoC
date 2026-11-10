#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L612,585

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the totalFee to zero. As a
result the expression will divide to zero and the transaction will revert.

|Criticality|critical|
|---|---|
|Location|contract.sol#L612,585|

```
uint256 amountToLiquify =
swapThreshold.mul(dynamicLiquidityFee).div(totalFee).div(2);

```

Additionally, the contract owner has the authority to stop the sales for all users
excluding the owner for one day after the initial launch. The owner may take
advantage of it by setting the feeDenominator to a value greater than 18000. As a
result, the tokens will be more than the sender’s balance and the transactions will
revert.

```
if (launchedAtTimestamp + 1 days > block.timestamp) {
  return totalFee.mul(18000).div(feeDenominator);

```

##### Recommendation

The contract should embody a check for preventing the execution of the
```
swapBack() when the totalFee is zero.

```
Read more in the fees manipulation section.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

