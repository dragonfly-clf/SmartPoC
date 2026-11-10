#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L663

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting a high value to sellFeet.

|Criticality|critical|
|---|---|
|Location|contract.sol#L663|

```
if (recipient == pair) {
  _totalFee =
    totalFee.add(sellFeet).add(sellFeef)
    .add(sellFeel);

```

##### Recommendation

Check the Exceed Limit Fees Manipulation section.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

