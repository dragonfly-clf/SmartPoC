#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L1305

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The contract owner can also convert the contract into a honeypot and
prevent users from selling by increasing the selling taxes (sellRewardFeeRate,
sellMarketingFeeRate).

|Criticality|critical|
|---|---|
|Location|contract.sol#L1305|

```
else if (lpAddresses[recipient]) {//sell
       feeRate = sellRewardFeeRate + sellMarketingFeeRate;
}
//
if (feeRate > 0 && !excludeFee[sender] && !excludeFee[recipient] && recipient
!= marketingAddress) {
       uint256 fee = amount.mul(feeRate).div(100);
       amount = amount.sub(fee);

```

##### Recommendation

The contract could embody a check for not allowing setting the sellRewardFeeRate
and sellMarketingFeeRate more than a reasonable amount.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

