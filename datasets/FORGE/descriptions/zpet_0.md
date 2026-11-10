#### OCTD - Transfers Contract's Tokens

|Criticality|Minor / Informative|
|---|---|
|Location|ZeusPet.sol#L251|
|Status|Multisign|


##### Description


The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the rescueToken function.


##### Recommendation


The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. Some suggestions are:

 - Introduce a time-locker mechanism with a reasonable delay.

 - Introduce a multi-sign wallet so that many addresses will confirm the action.

 - Introduce a governance model where users will vote about the actions.

 - Renouncing the ownership will eliminate the threats but it is non-reversible.


##### Team Update


The team has implemented our recommendation by adopting a multi-signature
wallet at the following transaction
[https://bscscan.com/tx/0xdee6c8c9d2325b6127a516f1c2aeb281a4434424888b34](https://bscscan.com/tx/0xdee6c8c9d2325b6127a516f1c2aeb281a4434424888b347a3616a5860f513dd4)
[7a3616a5860f513dd4](https://bscscan.com/tx/0xdee6c8c9d2325b6127a516f1c2aeb281a4434424888b347a3616a5860f513dd4)


-----

