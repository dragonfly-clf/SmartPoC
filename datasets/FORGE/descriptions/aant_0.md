#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L1070

##### Description

The contract owner has the authority to stop selling for all users excluding the
owner. The owner may take advantage of it by setting maxSellTransactionAmount
to a very low value. This way the contract will operate as a honeypot.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1070|

```
 if(!swapping && automatedMarketMakerPairs[to] && from !=
address(uniswapV2Router) && !_isExcludedFromFees[to])
    {
       require(amount <= maxSellTransactionAmount, "Amount exceeds the
Protocol-X");
    }

```

##### Recommendation

The contract could embody a check for not allowing setting
```
maxSellTransactionAmount less than a reasonable amount. A suggested

```
implementation could check that the maximum amount should be more than a fixed
percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

