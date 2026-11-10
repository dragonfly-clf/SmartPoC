#### ST - Stops Transactions

|Criticality|Critical|
|---|---|
|Location|GoldHunt.sol#L338,344|
|Status|Unresolved|


##### Description


The contract utilizes the variable rebaseMultiple. If this variable is altered by the
```
rebase function, it will cause the contract to halt transactions for all users. The

```
following example depits this issue.

Assuming a user owns 10 tokens and the rebase function is triggered, setting the
```
rebaseMultiple to 10. If the user tries to transfer these 10 tokens to another

```
address, the transaction will fail because the rebaseMultiple will multiply the transfer
amount to 100 tokens, which the user does not have.


##### Recommendation


The contract could remove the rebaseMultiple. The team should carefully
manage the private keys of the owner’s account. We strongly recommend a
powerful security mechanism that will prevent a single user from accessing the
contract admin functions. That risk can be prevented by temporarily locking the
contract or renouncing ownership.


-----

