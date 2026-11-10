#### BC - Blacklists Addresses


#### Description


The contract owner has the authority to stop addresses from transactions. The owner may


take advantage of it by calling the `setBlacklist` function.


#### Recommendation


The team should carefully manage the private keys of the owner’s account. We strongly


recommend a powerful security mechanism that will prevent a single user from accessing


the contract admin functions. Some suggestions are:



- Introduce a time-locker mechanism with a reasonable delay.

- Introduce a multi-sign wallet so that many addresses will confirm the action.

- Introduce a governance model where users will vote about the actions.

- Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

#### Team Update


The team has acknowledged that this is not a security issue and states:


"Has been added on as a security fallback incase needed for compliance against malicious


_actors. This again is part of the DAO governance."_


-----

