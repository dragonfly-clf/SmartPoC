#### ST - Stops Transactions

|Criticality|Medium|
|---|---|
|Location|BullsRunToken.sol#L479|
|Status|Unresolved|


##### Description


The contract owner has the authority to stop all users from buying excluding the
owner. The owner may take advantage of it by setting the
```
cooldownTimerInterval to a high value.

```

##### Recommendation


The contract could embody a check for not allowing setting the
```
cooldownTimerInterval more than a reasonable amount. The team should

```
carefully manage the private keys of the owner’s account. We strongly recommend
a powerful security mechanism that will prevent a single user from accessing the
contract admin functions. Some suggestions are:

 - Introduce a time-locker mechanism with a reasonable delay.

 - Introduce a multi-sign wallet so that many addresses will confirm the action.

 - Introduce a governance model where users will vote about the actions.

 - Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

