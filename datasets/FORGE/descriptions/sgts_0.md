#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L1084,1087,1097

##### Description

The contract owner has the authority to stop transactions for all sales excluding the
owner. The owner may take advantage of it by setting the
```
maxSellTransactionAmount to zero.

```
|Criticality|critical|
|---|---|
|Location|contract.sol#L1084,1087,1097|

```
if(!swapping && automatedMarketMakerPairs[to] && from !=
address(uniswapV2Router) && !_isExcludedFromFees[to])
{
  require(amount <= maxSellTransactionAmount, "Amount exceeds the
Protocol-X");
}

```

The contract owner has the authority to stop transactions for all buys excluding the
owner. The owner may take advantage of it by setting the
```
contractBalanceRecepient or maxBuyTranscationAmount to zero.

```
```
require(contractBalanceRecepient + amount <= _maxWalletToken, "Exceeds maximum
wallet token amount.");

```
```
require(amount <= maxBuyTranscationAmount, "Amount exceeds the Protocol-X.");

```

##### Recommendation

The contract could embody a check for not allowing setting the
_maxSellTransactionAmount, contractBalanceRecepient, and_
_maxBuyTranscationAmount less than a reasonable amount. A suggested_
implementation could check that the maximum amount should be more than a fixed
percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user


-----

from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

