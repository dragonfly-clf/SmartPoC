#### MT - Mints Tokens

**Criticality** Critical

**Location** CoinToken.sol#L1207

**Status** Unresolved

#### Description

The contract owner has the authority to mint tokens. The owner may take advantage of it by

calling the `mint` function. As a result, the contract tokens will be highly inflated.
```
 function mint(address account, uint256 amount) external canMint
 {
   _mint(account, amount);
 }
 function _mint(address account, uint256 amount) internal
 override onlyOwner {
   super._mint(account, amount);
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

