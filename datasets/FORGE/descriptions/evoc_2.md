#### ULTW - Transfers Liquidity to Team Wallet


#### Description


The contract owner has the authority to set the `totalFee` to zero. As a result, the


function `swapBack` will swap the contract’s tokens to the native currency and send the


swapped amount to the `marketingFeeReceiver .`


-----

12


#### Recommendation


The contract could embody a check for the maximum amount of funds that can be


swapped, since a huge amount may volatile the token's price. The team should carefully


manage the private keys of the owner’s account. We strongly recommend a powerful

security mechanism that will prevent a single user from accessing the contract admin


functions. Some suggestions are:



- Introduce a time-locker mechanism with a reasonable delay.

- Introduce a multi-sign wallet so that many addresses will confirm the action.

- Introduce a governance model where users will vote about the actions.

- Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

13


