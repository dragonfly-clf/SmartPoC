#### ST - Stop Transactions

**Criticality** medium

**Location** contract.sol#L1363

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the tradingActive to false.

|Criticality|medium|
|---|---|
|Location|contract.sol#L1363|

```
if(!tradingActive){
  require(_isExcludedFromFees[from] || _isExcludedFromFees[to], "Trading is
not active.");
 }

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

