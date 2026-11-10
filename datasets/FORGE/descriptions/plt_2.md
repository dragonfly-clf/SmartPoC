#### ST - Stop Transactions

**Criticality** medium

**Location** https://bscscan.com/address/0xd61b85636b4a5834c1e8a196da7218cebbf76c36#
code#L1

**Resolved** The contract owner has renounced the ownership. Hence, transactions cannot be
stopped.

##### Description

The contract owner has the authority to pause transactions. He can do that by
calling the pause function.

|Criticality|medium|
|---|---|
|Location|https://bscscan.com/address/0xd61b85636b4a5834c1e8a196da7218cebbf76c36# code#L1|
|Resolved|The contract owner has renounced the ownership. Hence, transactions cannot be stopped.|

```
 function transfer(address _to, uint256 _value) public whenNotPaused returns
(bool) {
  return super.transfer(_to, _value);
 }

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.