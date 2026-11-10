#### ST - Stops Transactions

**Criticality** Critical

**Status** Unresolved

#### Description

The contract owner has the authority to stop the sales for all users excluding the owner, as

described in detail in section PTRP. As a result, the contract may operate as a honeypot.

#### Recommendation

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

