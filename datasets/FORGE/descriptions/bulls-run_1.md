#### OTUT - Transfers User's Tokens

|Criticality|Minor / Informative|
|---|---|
|Location|BullsRunToken.sol#L687,714|
|Status|Unresolved|


##### Description


The contract owner has the authority to transfer the balance of a user's address to
any address or addresses without allowance. The owner may take advantage of it
by calling the multiTransfer or multiTransfer_fixed functions.


##### Recommendation


The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. Some suggestions are:

 - Introduce a time-locker mechanism with a reasonable delay.

 - Introduce a multi-sign wallet so that many addresses will confirm the action.

 - Introduce a governance model where users will vote about the actions.

 - Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

