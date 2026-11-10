#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L433,L441,L447,L452

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by:

Setting a high amount to the sell fees.

|Criticality|critical|
|---|---|
|Location|contract.sol#L433,L441,L447,L452|

```
if(recipient == pair){
  sellFees();
}

```

Setting the _maxSellTxAmount to zero and disabling the autoLimits variable.

```
if(recipient == pair){
  require(amount <= _maxSellTxAmount || isTxLimitExempt[sender], "TX Limit
Exceeded");
}

```

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by:

Setting the tradingOpen to false.

```
if(!authorizations[sender] && !authorizations[recipient]){
  require(tradingOpen,"Trading not open yet");
}

```

Setting the _maxWalletToken to zero.

```
require((heldTokens + amount) <= _maxWalletToken,"Total Holding is currently
limited, you can not buy that much.");}

```

-----

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

