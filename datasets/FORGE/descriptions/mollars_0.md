#### ST - Stops Transactions

**Criticality** Critical

**Location** MOLLARS.sol#L382

**Status** Unresolved

#### Description

The transactions are initially disabled for all users excluding the authorized addresses. The

owner can enable the transactions for all users. Once the transactions are enable the owner

will not be able to disable them again.

Additionally, the contract owner has the authority to stop the sales for all users excluding

the owner, as described in detail in section `PVC` and `PTRP . As a result, the contract`

may operate as a honeypot.
```
 if (!isFeeExempt[sender] && !isFeeExempt[recipient]) {
   // trading disable till launch
   if (!trading) {
      require(
        pair != sender && pair != recipient,
        "Trading is disable"
      );
   }

#### Recommendation

```
The team is strongly encouraged to adhere to the recommendations outlined in the

respective sections. The team should carefully manage the private keys of the owner’s

account. We strongly recommend a powerful security mechanism that will prevent a single

user from accessing the contract admin functions. Some suggestions are:

  - Introduce a multi-sign wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.


-----

