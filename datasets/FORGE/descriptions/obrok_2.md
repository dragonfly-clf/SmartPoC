#### BC - Blacklisted Contracts

**Criticality** medium

**Location** https://bscscan.com/address/0x205afd08cefe438377a0abc5a20cb4462e1a8c5c
#code#L253

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the blacklistAddress function.

|Criticality|medium|
|---|---|
|Location|https://bscscan.com/address/0x205afd08cefe438377a0abc5a20cb4462e1a8c5c #code#L253|

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
renouncing ownership.