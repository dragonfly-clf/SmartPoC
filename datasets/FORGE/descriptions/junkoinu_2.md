#### ST - Stop Transactions

**Criticality** high

**Location** https://bscscan.com/address/0x8983a6f5b70315f9373d39e14de5afeabf835588#co
de#L1145

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x8983a6f5b70315f9373d39e14de5afeabf835588#co de#L1145|

```
if(from != owner() && to != owner())
  require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.