#### ULTW - Transfers Liquidity to Team Wallet

|Criticality|Critical|
|---|---|
|Location|BEP20LUNAINU.sol#L532|
|Status|Unresolved|


##### Description


The contract owner has the authority to transfer up to 5% of the liquidity pool to his
waller every 2 minutes. If this functionality is abused by the contract owner, then the
liquidity pool will be significantly decreased and the users will not be able to trade
their tokens.

Additionally, the method name lunaburn intuitively means that the contract burns
tokens. On the contrary, the contract moved the liquidity tokens to the owner's
address.


##### Recommendation


The team is advised to limit the liquidity drain in a more reasonable time and
quantity amount. The team should carefully manage the private keys of the owner’s
account. We strongly recommend a powerful security mechanism that will prevent a
single user from accessing the contract admin functions. That risk can be prevented
by temporarily locking the contract or renouncing ownership.


-----

