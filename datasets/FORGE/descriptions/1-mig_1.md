#### OCTD - Transfers Contract's Tokens

**Criticality** Minor / Informative

**Location** CoinToken.sol#L1132

**Status** Unresolved

#### Description

The contract owner has the authority to claim all the balance of the contract. The owner

may take advantage of it by calling the `recoverERC20` function.
```
 function recoverERC20(address tokenAddress, uint256
 tokenAmount) public virtual onlyOwner {
   IERC20(tokenAddress).transfer(owner(), tokenAmount);
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

