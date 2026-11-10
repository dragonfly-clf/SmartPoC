##### ST - Stop Transactions with Max Amount

**Criticality** high

**Location** https://bscscan.com/address/0x2df0c13487efdf4eb7f6c042273b7aca781b29a0#co
de#L1063

**Status** Resolved

###### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x2df0c13487efdf4eb7f6c042273b7aca781b29a0#co de#L1063|
|Status|Resolved|

```
if(from != owner() && to != owner())
  require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

```

###### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

###### Resolved

The team locked the contract and has no longer access to owner functions. The
contract will be locked until 10 January 2022
https://bscscan.com/tx/0x7bd85dd8c8c7c77a52d0e49c10a7044c5a9296606b8383
d85f30a785d897da69


-----

