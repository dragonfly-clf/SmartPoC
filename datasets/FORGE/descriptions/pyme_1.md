#### MT - Mints Tokens


#### Description


The contract owner has the authority to mint tokens. The owner may take advantage of it by


calling the `mint` function. As a result, the contract tokens will be highly inflated.


#### Recommendation


The team should carefully manage the private keys of the owner’s account. We strongly


recommend a powerful security mechanism that will prevent a single user from accessing


the contract admin functions. Some suggestions are:



- Introduce a time-locker mechanism with a reasonable delay.

- Introduce a multi-sign wallet so that many addresses will confirm the action.

- Introduce a governance model where users will vote about the actions.

- Renouncing the ownership will eliminate the threats but it is non-reversible.


#### Team Update


The team has acknowledged that this is not a security issue and states:


"Contract has a hardcap of 1B tokens and only 560,000,000 tokens in circulation for the


_moment. This means we need the mint feature for the DAO to mint additional tokens as and_


_when voted and needed."_


-----

