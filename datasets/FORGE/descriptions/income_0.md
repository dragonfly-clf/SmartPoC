#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L2074

**Status** Resolved

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the
```
maxSellTransactionAmount to zero.

```
|Criticality|critical|
|---|---|
|Location|contract.sol#L2074|
|Status|Resolved|

```
if(automatedMarketMakerPairs[to] && (!_isExcludedFromMaxTx[from]) &&
(!_isExcludedFromMaxTx[to])){
  require(amount <= maxSellTransactionAmount, "Sell transfer amount exceeds
the maxSellTransactionAmount.");
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

##### Updated 15 June 2022

The team has renounced ownership and resolved the issues.


-----

