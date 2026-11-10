#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L1026,1032,1076

##### Description

The contract owner has the authority to stop transactions for all sales or boughts
excluding the owner. The owner may take advantage of it by calling the
```
setMaxTransactionAmount or setMaxWalletAmount with a high number. As a

```
result the expression maxTxAmountSell = _tTotal / _maxTxAmountSellPct will
produce a significant small number. In practice, that number will not be enough for
the users to sell assuming that their holdings will be thousands.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1026,1032,1076|

```
function setMaxTransactionAmount(
  uint256 _maxTxAmountBuyPct,
  uint256 _maxTxAmountSellPct
) external onlyOwner {
  maxTxAmountBuy = _tTotal / _maxTxAmountBuyPct; // 100 = 1%, 50 = 2% etc.
  maxTxAmountSell = _tTotal / _maxTxAmountSellPct; // 100 = 1%, 50 = 2% etc.
}

```
```
require(
  amount <= maxTxAmountSell,
  "amount must be <= maxTxAmountSell"
);

```
```
require(
  amount <= maxTxAmountBuy,
  "amount must be <= maxTxAmountBuy"
);

```
```
require(
  _isExcludedFromMaxWallet[recipient] ||
    balanceOf(recipient) <= maxWalletAmount,

```

-----

```
  "Recipient cannot hold more than maxWalletAmount"
);

```

##### Recommendation

The contract could embody a check for not allowing setting the maxTxAmountBuy,
_maxTxAmountSell and maxTxAmountBuy less than a reasonable amount. A_
suggested implementation could check that the maximum amount should be more
than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

