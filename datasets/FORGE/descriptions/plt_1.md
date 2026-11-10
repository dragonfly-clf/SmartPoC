#### BC - Blacklisted Contracts

**Criticality** medium

**Location** https://bscscan.com/address/0xd61b85636b4a5834c1e8a196da7218cebbf76c3
6#code#L220

**Resolved** The contract owner has renounced the ownership. Hence, addresses cannot be
blacklisted.

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the blacklistAddress function.

|Criticality|medium|
|---|---|
|Location|https://bscscan.com/address/0xd61b85636b4a5834c1e8a196da7218cebbf76c3 6#code#L220|
|Resolved|The contract owner has renounced the ownership. Hence, addresses cannot be blacklisted.|

```
 function blackListAddress(address listAddress, bool isBlackListed) public
whenNotPaused onlyOwner returns (bool success) {
    return super._blackList(listAddress, isBlackListed);
 }

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

