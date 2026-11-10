#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L699,L801

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero.

|Criticality|critical|
|---|---|
|Location|contract.sol#L699,L801|

```
if(!isTxLimitExempt[sender] && !isTxLimitExempt[recipient]) {
  require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
}

```

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the _totalTaxIfSelling to 100.

```
else if(isMarketPair[recipient]) {
  feeAmount = amount.mul(_totalTaxIfSelling).div(100);
}

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

Additionally there should be a check for the maximum amount of fees that the
contract owner is able to set. Read more on the ELFM section.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

