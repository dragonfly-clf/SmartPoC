#### ST - Stop Transactions

**Criticality** medium

**Location** https://polygonscan.com/address/0xb7ba576c526cfafc77e47b4959eb6c67504d54
25#code#L1150

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero.

|Criticality|medium|
|---|---|
|Location|https://polygonscan.com/address/0xb7ba576c526cfafc77e47b4959eb6c67504d54 25#code#L1150|

```
if(from != owner() && to != owner())
  require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");
if(from != owner() && to == uniswapV2Pair)
  require(_maxSellAmount > amount, "Transfer amount exceeds max Sell
Amount.");
if(from == uniswapV2Pair && to != owner())
  require(_maxBuyAmount > amount, "Transfer amount exceeds max Buy Amount.");

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.