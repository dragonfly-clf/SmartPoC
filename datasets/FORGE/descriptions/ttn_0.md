### ST - Stops Transactions

**Criticality** Critical

**Location** TRITON.sol#L1453

**Status** Unresolved

### Description

The transactions are initially disabled for all users excluding the authorized addresses. The

owner can enable the transactions for all users. Once the transactions are enable the owner

will not be able to disable them again.
```
 if (!canTransferBeforeTradingIsEnabled[from]) {
   require(tradingEnabled, "Trading has not yet been
 enabled");
 }

### Recommendation

```
The contract could embody a check for not allowing setting the `_maxTxAmount` less

than a reasonable amount. A suggested implementation could check that the minimum

amount should be more than a fixed percentage of the total supply. The team should

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

