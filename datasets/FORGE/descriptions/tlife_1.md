#### OCTD - Transfers Contract's Tokens

**Criticality** Minor / Informative

**Location** TLIFE_Coin.sol#L109

**Status** Unresolved

#### Description

The contract owner has the authority to claim all the tokens held by the contract. The owner

may take advantage of it by calling the `recoverToken` function.
```
   function recoverToken(address tokenAddress, uint256
 tokenAmount) public virtual onlyOwner {
      IERC20(tokenAddress).transfer(owner(), tokenAmount);
   }

#### Recommendation

```
The team should carefully manage the private keys of the owner’s account. We strongly

recommend a powerful security mechanism that will prevent a single user from accessing

the contract admin functions. Some suggestions are:

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a multi-sign wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.

  - Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

