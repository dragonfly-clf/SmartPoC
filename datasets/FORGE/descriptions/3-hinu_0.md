#### ST - Stops Transactions

|Criticality|Critical|
|---|---|
|Location|contracts/honeyether.sol#L2384|
|Status|Unresolved|


##### Description


The contract owner has the authority to stop the sales for all users. The owner may
take advantage of it by:

1. Changing the dividendTracker to an untrusted source.

2. Setting the trades to false.

3. Setting the fees to a value greater than 100.


##### Recommendation


The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

