#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L1573

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the
```
maxSellTransactionAmount to zero.

```
|Criticality|critical|
|---|---|
|Location|contract.sol#L1573|

```
if(
  !swapping &&
  automatedMarketMakerPairs[to] && // sells only by detecting transfer to
automated market maker pair
  from != address(uniswapV2Router) && //router -> pair is removing liquidity
which shouldn't have max
  !_isExcludedFromFees[from] //no max for those excluded from fees
) {
  require(amount <= maxSellTransactionAmount, "Sell transfer amount exceeds
the maxSellTransactionAmount.");
}

```

##### Recommendation

The contract could embody a check for not allowing setting the
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

