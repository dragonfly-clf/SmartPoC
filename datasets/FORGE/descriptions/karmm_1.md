#### OCTD - Transfers Contract's Tokens

**Criticality** Minor / Informative

**Location** KARMMToken.sol#L656

**Status** Unresolved

#### Description

The contract owner has the authority to claim all the balance of the contract. The owner

may take advantage of it by calling the `withdrawTokens` function.
```
   function withdrawTokens(address to, uint256 amount) external
 onlyOwner {
      require(to != address(0), "Invalid address");
      require(amount > 0, "Amount must be greater than
 zero");
      require(balanceOf(address(this)) >= amount,
 "Insufficient balance in the contract");
      _transfer(address(this), to, amount);
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

