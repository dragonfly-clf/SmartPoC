#### BC - Blacklists Addresses

|Criticality|Medium|
|---|---|
|Location|CamKingToken.sol#L861|
|Status|Unresolved|


##### Description


The contract owner has the authority to stop addresses from transactions. The
owner may take advantage of it by calling the blacklistAccount function.


##### Recommendation


The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

