#### ST - Stops Transactions


#### Description


The transactions are initially disabled for all users excluding the authorized addresses. The


owner can enable the transactions for all users. Once the transactions are enable the owner


will not be able to disable them again.


#### Recommendation


The team should carefully manage the private keys of the owner’s account. We strongly


recommend a powerful security mechanism that will prevent a single user from accessing


the contract admin functions. Some suggestions are:



- Introduce a multi-sign wallet so that many addresses will confirm the action.

- Introduce a governance model where users will vote about the actions.


-----

