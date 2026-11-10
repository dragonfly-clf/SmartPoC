#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L662

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxSellTxAmount or
```
_maxBuyTxAmount the to zero.

```
If the _maxSellTxAmount is set to zero, the contract will behave like a honeypot
since the holders will not be able to sell their tokens.

|Criticality|critical|
|---|---|
|Location|contract.sol#L662|

```
function checkTxLimit(address sender, uint256 amount, address recipient, bool
isSell) internal view {
  if (recipient != owner){
    if(isSell){
       require(amount <= _maxSellTxAmount || isTxLimitExempt[sender] ||
isTxLimitExempt[recipient], "TX Limit Exceeded");
    } else {
       require(amount <= _maxBuyTxAmount || isTxLimitExempt[sender] ||
isTxLimitExempt[recipient], "TX Limit Exceeded");
    }
  }
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

