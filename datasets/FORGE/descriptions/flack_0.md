#### ST - Stops Transactions

**Criticality** Critical

**Location** Flack.sol#L307,309

**Status** Unresolved

#### Description

The contract owner has the authority to stop the transactions for all users excluding the

authorized addresses. The owner may take advantage of it by setting the

`maxTransaction` to zero.
```
 require(amount <= maxTransaction, "Exceeds maxTxAmount");

```
The contract owner has the authority to stop the buys and transfers for all users excluding

the authorized addresses. The owner may take advantage of it by setting the `maxWallet`

to zero.
```
 if(!isMarketPair[recipient]) {
   require(balanceOf(recipient).add(amount) <= maxWallet, "Exceeds
 maxWallet");
 }

```
The contract owner has the authority to stop the sales for all users excluding the authorized

addresses. The owner may take advantage of it by setting the `sellFee` over 100%.

Additionally, the issues, which are described in details, in sections PLPI, PTRP, and PVC

can also result in the suspension of sales. As a result, the contract may operate as a

honeypot.


-----

#### Recommendation

The contract could embody a check for not allowing setting the `maxTransaction` and

`maxWallet` less than a reasonable amount. A suggested implementation could check

that the minimum amount should be more than a fixed percentage of the total supply. The

team should carefully manage the private keys of the owner’s account. We strongly

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

