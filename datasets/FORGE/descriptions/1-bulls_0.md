#### ST - Stops Transactions

**Criticality** Medium

**Location** bullstoken.sol#L647

**Status** Unresolved

#### Description

The contract owner has the authority to stop the transactions for all users. The owner may

take advantage of it by setting the:

  - `maxHoldingAmount` to zero.

  - `minHoldingAmount` to a large value.
```
 if (limited && from == uniswapV2Pair) {
   require(super.balanceOf(to) + amount <= maxHoldingAmount &&
 super.balanceOf(to) + amount >= minHoldingAmount, "Forbid");
 }

#### Recommendation

```
The contract could embody a check for not allowing setting the `maxHoldingAmount`

less than a reasonable amount or the `minHoldingAmount` more than a reasonable

amount. A suggested implementation could check that the minimum/maximum amount

should be more than a fixed percentage of the total supply. The team should carefully

manage the private keys of the owner’s account. We strongly recommend a powerful

security mechanism that will prevent a single user from accessing the contract admin

functions. Some suggestions are:

  - Introduce a time-locker mechanism with a reasonable delay.

  - Introduce a multi-sign wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.

  - Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

