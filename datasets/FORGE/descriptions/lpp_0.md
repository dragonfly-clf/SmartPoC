#### ST - Stops Transactions


#### Description


The contract authorized users have the authority to stop the transactions for all users


excluding the authorized users. The authorized users may take advantage of it by setting


the `MaxTx` to zero or `MinTx` to the max `uint256` value.


-----

#### Recommendation


The contract could embody a check for not allowing setting the `MaxTx` less than a


reasonable amount and the `MinTx` more than a reasonable amount. A suggested

implementation could check that the maximum amount should be more than a fixed


percentage of the total supply. The team should carefully manage the private keys of the


owner’s account. We strongly recommend a powerful security mechanism that will prevent


a single user from accessing the contract admin functions.


Temporary Solutions:


These measurements do not decrease the severity of the finding



- Introduce a time-locker mechanism with a reasonable delay.

- Introduce a multi-signature wallet so that many addresses will confirm the action.

- Introduce a governance model where users will vote about the actions.


Permanent Solution:



- Renouncing the ownership, which will eliminate the threats but it is non-reversible.


-----

