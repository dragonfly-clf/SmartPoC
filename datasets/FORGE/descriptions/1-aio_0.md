#### BT - Burns Tokens

**Criticality** Critical

**Location** AIOToken.sol#L229

**Status** Renounced

#### Description

The `onlyTokenBurner` role has the authority to burn tokens from a specific address.

The user role may take advantage of it by calling the `burn` function. As a result, the

targeted address will lose the corresponding tokens.
```
   function burn(
      address account,
      uint256 amount
   ) external onlyTokenBurner returns (bool) {
      _burn(account, amount);
      return true;
   }

#### Recommendation

```
The team should carefully manage the private keys of the tokenBurner’s account. We

strongly recommend a powerful security mechanism that will prevent a single user from

accessing the contract admin functions. Some suggestions are:

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a multi-sign wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.

  - Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

