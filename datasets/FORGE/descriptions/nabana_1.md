#### BC - Blacklists Addresses

|Criticality|Critical|
|---|---|
|Location|Nabana.sol#L1958|
|Status|Unresolved|


##### Description


The contract owner has the authority to massively stop addresses from
transactions. The owner may take advantage of it by calling the
```
blackListMultipleAddresses function.

```

##### Recommendation


The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

