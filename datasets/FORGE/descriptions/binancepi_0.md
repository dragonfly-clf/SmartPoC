#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L682,784

##### Description

The contract owner has the authority to stop sales for all users excluding the owner.
The owner may take advantage of it by setting the _totalTaxIfSelling to a high
value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L682,784|

```
else if(isMarketPair[recipient]) {
  feeAmount = amount.mul(_totalTaxIfSelling).div(100);
}

```

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero.

```
if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
  require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
}

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

Read more about the sale taxes in the Exceed Limit Fees Manipulation section.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Corrected 21 March 2022


-----

The team has renounced ownership and the threat has been eliminated.


-----

