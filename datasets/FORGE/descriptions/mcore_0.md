#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L1190

##### Description

The contract owner has the authority to stop sales or buys for all users excluding
the owner. The owner may take advantage of it by setting the buyLimit or
```
sellLimit to zero.

```
|Criticality|critical|
|---|---|
|Location|contract.sol#L1190|

```
if (isBuyOrder(from, to)) require(amount < buyLimit, "Try a smaller amount");
if (isSellOrder(from, to)) require(amount < sellLimit, "Try a smaller amount");

```

##### Recommendation

The contract could embody a check for not allowing setting the buyLimit and
sellLimit less than a reasonable amount. A suggested implementation could check
that the maximum amount should be more than a fixed percentage of the total
supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

