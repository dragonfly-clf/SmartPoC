#### ST - Stops Transactions

|Criticality|medium|
|---|---|
|Location|DiamondDexToken.sol#L1350|
|Status|renounced|


##### Description


The contract owner has the authority to stop the transactions for all users excluding
the owner. The owner may take advantage of it by setting the _maxTxAmount to
zero.


##### Recommendation


The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


##### Team Update


The team renounced ownership in the following transaction:
[https://bscscan.com/tx/0x74ec1e9a99eaeda7ae6081eefdb63b5feba6e7bd71ffae17](https://bscscan.com/tx/0x74ec1e9a99eaeda7ae6081eefdb63b5feba6e7bd71ffae17d653cca5c0389219)
[d653cca5c0389219](https://bscscan.com/tx/0x74ec1e9a99eaeda7ae6081eefdb63b5feba6e7bd71ffae17d653cca5c0389219)


The variable _maxTxAmount is locked at 10% of the totalSupply.


-----

