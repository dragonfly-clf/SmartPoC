#### ST - Stops Transactions


#### Description


The contract owner has the authority to stop the sales for all users excluding the


`whitelist` address. The owner may whitelist their own addresses or those of their


associates, effectively allowing only a select few to transact. As a result, the contract may


operate as a honeypot.


#### Recommendation


It is recommended that the project could consider removing the `pause` functionality from


the contract entirely. The team should carefully manage the private keys of the owner’s


-----

account. We strongly recommend a powerful security mechanism that will prevent a single


user from accessing the contract admin functions. Some suggestions are:



- Introduce a time-locker mechanism with a reasonable delay.

- Introduce a multi-sign wallet so that many addresses will confirm the action.

- Introduce a governance model where users will vote about the actions.

- Renouncing the ownership will eliminate the threats but it is non-reversible.


#### Team Update


The team has acknowledged that this is not a security issue and states:


"Ability added-in post voting the DAO to stop trading activity until listing of the token."


-----

