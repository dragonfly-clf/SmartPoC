#### ST - Stops Transactions

**Criticality** Critical

**Location** MitaoCat.sol#L421

**Status** Unresolved

#### Description

The transactions are initially disabled for all users excluding the authorized addresses. The

owner can enable the transactions for all users. Once the transactions are enable the owner

will not be able to disable them again.
```
 if(!tradingActive){
   require(_isExcludedFromFees[from] || _isExcludedFromFees[to],
 "Trading is not active.");
 }

#### Recommendation

```
The team should carefully manage the private keys of the owner’s account. We strongly

recommend a powerful security mechanism that will prevent a single user from accessing

the contract admin functions. Some suggestions are:

  - Introduce a multi-sign wallet so that many addresses will confirm the action.

  - Introduce a governance model where users will vote about the actions.


-----

