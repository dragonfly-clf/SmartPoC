#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L738,845

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting a high value to
```
_totalTaxIfSelling. This can cause the contract to operate as a honeypot.

```
|Criticality|critical|
|---|---|
|Location|contract.sol#L738,845|

```
else if(isMarketPair[recipient]) {
  feeAmount = amount.mul(_totalTaxIfSelling.sub(_sellDestroyFee)).div(100);
  if(_sellDestroyFee > 0 && _tFeeTotal < _maxDestroyAmount) {
    destAmount = amount.mul(_sellDestroyFee).div(100);
    destroyFee(sender,destAmount);
  }
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

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

