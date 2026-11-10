#### ST - Stop Transactions

**Criticality** medium

**Location** contract.sol#L962,1012

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the _sellTaxFee to a high
value.

|Criticality|medium|
|---|---|
|Location|contract.sol#L962,1012|

```
if (takeFee && to == _pancakeswapV2LiquidityPair) {
  // We will assume that the normal sell tax rate will apply
  uint256 fee = _sellTaxFee;

```

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero.

```
if(from != owner() && to != owner()) {
  require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
}

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

Read more about the stop sales recommendation in the limit fees manipulation
section.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

