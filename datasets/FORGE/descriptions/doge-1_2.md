#### BC - Blacklisted Contracts

**Criticality** medium

**Location** https://bscscan.com/address/0xBF5C0dcFd2925fC2f4324cf3E0C9f31C0E36F771#
code#L605

##### Description

The contract owner has the authority to stop contracts from transactions. The owner
may take advantage of it by calling the _isSniper function.

|Criticality|medium|
|---|---|
|Location|https://bscscan.com/address/0xBF5C0dcFd2925fC2f4324cf3E0C9f31C0E36F771# code#L605|

```
require(!_isSniper[to], "You have no power here!");
require(!_isSniper[msg.sender], "You have no power here!");

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.