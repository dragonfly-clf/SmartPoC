#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L418,420

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero.

|Criticality|critical|
|---|---|
|Location|contract.sol#L418,420|

```
require(amount <= maxTxAmount,"Amount is exceeding maxTxAmount");

```

The contract owner has the authority to stop the sales or buys for all users
excluding the owner. The owner may take advantage of it by setting the
```
coolDownTime to a high value. As a result the users will not be able to trade after

```
their first transaction.

```
if(from != pair && coolDownEnabled){
  uint256 timePassed = block.timestamp - _lastTrade[from];
  require(timePassed > coolDownTime, "You must wait coolDownTime");
  _lastTrade[from] = block.timestamp;
}
if(to != pair && coolDownEnabled){
  uint256 timePassed2 = block.timestamp - _lastTrade[to];
  require(timePassed2 > coolDownTime, "You must wait coolDownTime");
  _lastTrade[to] = block.timestamp;
}

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
and coolDownTime more than a reasonable amount. A suggested implementation
could check that the maximum amount should be more than a fixed percentage of
the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user


-----

from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

