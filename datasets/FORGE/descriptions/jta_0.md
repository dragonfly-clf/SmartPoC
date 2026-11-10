#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L486

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the tradingOpen to false.

|Criticality|critical|
|---|---|
|Location|contract.sol#L486|

```
if (!authorizations[sender] && !authorizations[recipient]) {
      require(tradingOpen, "Trading is not enabled");

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

