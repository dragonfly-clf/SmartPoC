##### ST - Stop Transactions with Locked Flag

**Criticality** high

**Location** https://bscscan.com/address/0x2df0c13487efdf4eb7f6c042273b7aca781b29a0#co
de#L1234

**Status** Resolved

###### Description

The contract owner has the authority to stop transactions. The owner may take
advantage of it by setting the locked to zero.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x2df0c13487efdf4eb7f6c042273b7aca781b29a0#co de#L1234|
|Status|Resolved|

```
function transferLock() public onlyOwner {
  locked = true;
}

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

