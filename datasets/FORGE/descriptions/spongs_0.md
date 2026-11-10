#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L1769,L1809

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting by disabling the
```
isTradingEnabled variable.

```
|Criticality|critical|
|---|---|
|Location|contract.sol#L1769,L1809|

```
if(!isTradingEnabled) {
  require(_isAllowedDuringDisabled[to] || _isAllowedDuringDisabled[from],
"Trading is currently disabled");
}

```

The contract owner has the authority to prevent the sale of the token and allow only
the buy operations. The owner may take advantage of it by setting the
maxSellTransactionAmount to zero.

```
if(automatedMarketMakerPairs[to]){
  require(amount <= maxSellTransactionAmount, "BEP20: Exceeds max sell
amount");

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

