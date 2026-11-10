#### ST - Stop Transactions

**Criticality** high

**Location** https://bscscan.com/address/0x7fA6f63B11CC1af508cD19Ba823853d6aaCd9d65#
code#L1015

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to a very
small value and interrupt everyone else from trading apart from himself.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x7fA6f63B11CC1af508cD19Ba823853d6aaCd9d65# code#L1015|

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