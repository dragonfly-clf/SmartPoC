#### ST - Stop Transactions

**Criticality** medium

**Location** contract.sol#L1091

##### Description

The contract owner has the authority to stop transactions after their first transaction.
For instance, if a user buys then he may not be able to sell again. The owner may
take advantage of it by setting the timeDelay to a high number.

|Criticality|medium|
|---|---|
|Location|contract.sol#L1091|

```
if (delayBetweenTransfer[sendAddress] > 0) {
  require(
    delayBetweenTransfer[sendAddress] <= block.timestamp,
    "You must wait a bit to make another transaction"
  );
}
delayBetweenTransfer[sendAddress] =
  block.timestamp +
  timeDelay *
  1 seconds;

```

##### Recommendation

The contract could embody a check for not allowing setting the timeDelay more
than a reasonable amount.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

