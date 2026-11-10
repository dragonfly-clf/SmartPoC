#### ST - Stops Transactions

|Criticality|Minor / Informative|
|---|---|
|Location|BEP20LUNAINU.sol#L356|
|Status|Unresolved|


##### Description


The contract owner has the authority to stop the transactions for all users. The
owner may take advantage of it by setting the tradingOpen to false if the
```
launchMode has not been enabled yet.

```

##### Recommendation


The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

