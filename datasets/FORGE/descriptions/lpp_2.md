#### BC - Blacklists Addresses

**Criticality** Critical

**Location** LinerPowerPoint.sol#L470

**Status** Unresolved

#### Description

The contract owner has the authority to stop addresses from transactions. The owner may

take advantage of it by calling the `addBots` function.
```
 function addBots(address[] memory _botAddress, bool _status)
 external onlyOwner{
  for(uint256 i = 0; i < _botAddress.length; i++){
     botlist[_botAddress[i]] = _status;
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

