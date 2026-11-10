#### ST - Stops Transactions

|Criticality|Critical|
|---|---|
|Location|CHITAVERSE.sol#L283,292|
|Status|Unresolved|


##### Description


The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the cooldownTimerInterval
to a high value. As a result, the contract may operate as a honeypot.


##### Recommendation


The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply. The
contract should also prevent the cooldownTimerInterval to be more than a
reasonable amount. The team should carefully manage the private keys of the
owner’s account. We strongly recommend a powerful security mechanism that will
prevent a single user from accessing the contract admin functions. That risk can be
prevented by temporarily locking the contract or renouncing ownership.


-----

