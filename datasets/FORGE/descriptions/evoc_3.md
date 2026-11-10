#### MT - Mints Tokens


#### Description


The minter role has the authority to mint tokens up to 10000000000 tokens which are 330%


more than the initial supply. The owner may take advantage of it by calling the `mint`


function. As a result, the contract tokens will be highly inflated.


#### Recommendation


The team should carefully manage the private keys of the owner’s account. We strongly


recommend a powerful security mechanism that will prevent a single user from accessing


the contract admin functions. Some suggestions are:



- Introduce a time-locker mechanism with a reasonable delay.

- Introduce a multi-sign wallet so that many addresses will confirm the action.

- Introduce a governance model where users will vote about the actions.

- Renouncing the ownership will eliminate the threats but it is non-reversible.


#### Team Update


The team responded with the following statement:


_"We added this feature because it is necessary for our project. We will have stakes and_

_farms in our DEX (decentralized exchange), and the contract will need to mint tokens to_


_make payments to those who are staking."_


-----

14


