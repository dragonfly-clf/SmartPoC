#### ST - Stop Transactions

**Criticality** medium

**Location** contract.sol#L583

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the maxTxAmount or
```
maxTokenPerWallet to zero.

```
|Criticality|medium|
|---|---|
|Location|contract.sol#L583|

```
if(!isExcludedFromMaxTokenPerTx[from])
{
    require(amount <= maxTxAmount, "Transfer amount exceeds the
maxTxAmount.");
}
if(!isExcludedFromMaxTokenPerWallet[to] && !automatedMarketMakerPairs[to]){
    uint256 balanceRecepient = balanceOf(to);
    require(balanceRecepient + amount <= maxTokenPerWallet, "Exceeds maximum
token per wallet limit");
}

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount or
maxTokenPerWallet less than a reasonable amount. A suggested implementation
could check that the maximum amount should be more than a fixed percentage of
the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

