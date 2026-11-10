#### ELFM - Exceeds Fees Limit

**Criticality** Critical

**Location** LinerPowerPoint.sol#L476

**Status** Unresolved

#### Description

The contract owner has the authority to increase over the allowed limit of 25%. The owner

may take advantage of it by calling the `changeBurnFee` function with a high percentage

value.
```
 function changeBurnFee(uint256 _newburnFee, uint256
 _newburnDivisor) external onlyOwner{
  _burnFee = _newburnFee;
  _burnDivisor = _newburnDivisor;
 }

#### Recommendation

```
The contract could embody a check for the maximum acceptable value. The team should

carefully manage the private keys of the owner’s account. We strongly recommend a

powerful security mechanism that will prevent a single user from accessing the contract

admin functions.

Temporary Solutions:

These measurements do not decrease the severity of the finding

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a multi-signature wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.

Permanent Solution:

  - Renouncing the ownership, which will eliminate the threats but it is non-reversible.


-----

