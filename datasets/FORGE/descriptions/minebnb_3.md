#### BC - Blacklists Addresses

**Criticality** Critical

**Location** MineBNB.sol#L636

**Status** Renounced

#### Description

The contract owner has the authority to stop addresses from transactions. The owner may

take advantage of it by calling the `manage_blacklist` function.
```
 function manage_blacklist(address[] calldata addresses, bool status)
 public onlyOwner {
   for (uint256 i; i < addresses.length; ++i) {
     isBlacklisted[addresses[i]] = status;
   }
 }

#### Recommendation

```
The team should carefully manage the private keys of the owner’s account. We strongly

recommend a powerful security mechanism that will prevent a single user from accessing

the contract admin functions.

Temporary Solutions:

These measurements do not decrease the severity of the finding

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a multi-signature wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.

Permanent Solution:

  - Renouncing the ownership, which will eliminate the threats but it is non-reversible.


-----

#### Team Update


The contract's ownership has been renounced. The information regarding the transaction

can be accessed through the following link:

[https://bscscan.com/tx/0xb6e78aed438c4604d57e12125e9014a1f8ec3b1fc1b9d5effb22c6](https://bscscan.com/tx/0xb6e78aed438c4604d57e12125e9014a1f8ec3b1fc1b9d5effb22c6f060f3f5a7)

[f060f3f5a7.](https://bscscan.com/tx/0xb6e78aed438c4604d57e12125e9014a1f8ec3b1fc1b9d5effb22c6f060f3f5a7)


-----

