#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L302,323

**Status** Ownership renounced

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the variables that sum up the
```
swapFee to zero. As a result, the swapFee will produce a zero division revert.

```
|Criticality|critical|
|---|---|
|Location|contract.sol#L302,323|
|Status|Ownership renounced|

```
uint256 swapFee = _sellLPFee + _sellMarketingFee + _buyLPFee + _buyMarketingFee;
uint256 lpFee = _buyLPFee + _sellLPFee;
uint256 lpAmount = tokenAmount * lpFee / swapFee;

```

The contract owner may also take advantage of it by increasing the _sellLPFee to a
high value. As a result, the sender's amount will not be sufficient and the transaction
will revert.

```
if (isSell) {
  swapFee = _sellLPFee + _sellMarketingFee;
} else {
  swapFee = _buyLPFee + _buyMarketingFee;
}
uint256 swapAmount = tAmount * swapFee / 100;

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

Regarding the fees read more in the fees manipulation section.


-----

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Update 11/07

The contract has renounced the ownership, as a result the methods cannot be
abused.


-----

