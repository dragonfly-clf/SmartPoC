#### ST - Stop Transactions

**Criticality** medium

**Location** https://bscscan.com/address/0xe7c8f3d8422c185fd49d9fcc0b72f1d5d8614a44#co
de#L788

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero.

|Criticality|medium|
|---|---|
|Location|https://bscscan.com/address/0xe7c8f3d8422c185fd49d9fcc0b72f1d5d8614a44#co de#L788|

```
  if(from != owner() && to != owner())
       require(amount <= _maxTxAmount, "Transfer amount exceeds the
maxTxAmount.");

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

