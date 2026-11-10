#### ULTW - Transfers Liquidity to Team Wallet


#### Description


The contract `marketingWallet` has the authority to transfer funds without limit to the


team wallet. These funds have been accumulated from fees collected from the contract.


The owner may take advantage of it by calling the `getAllTaxes` method.


#### Recommendation


The contract could embody a check for the maximum amount of funds that can be


swapped, since a huge amount may volatile the token's price. The team should carefully


manage the private keys of the owner’s account. We strongly recommend a powerful

security mechanism that will prevent a single user from accessing the contract admin


functions.


Temporary Solutions:


These measurements do not decrease the severity of the finding



- Introduce a time-locker mechanism with a reasonable delay.

- Introduce a multi-signature wallet so that many addresses will confirm the action.

- Introduce a governance model where users will vote about the actions.


-----

