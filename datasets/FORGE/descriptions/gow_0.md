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


The ownership of the contract has been renounced, hence the mint method cannot be


called.


Transaction Hash:


[https://bscscan.com/tx/0xdf7ec7216e100d3fd8e439ba255990c4c23419ecb9e57ba1a504d](https://bscscan.com/tx/0xdf7ec7216e100d3fd8e439ba255990c4c23419ecb9e57ba1a504da5bcaebb19a)


[a5bcaebb19a](https://bscscan.com/tx/0xdf7ec7216e100d3fd8e439ba255990c4c23419ecb9e57ba1a504da5bcaebb19a)


-----

### Diagnostics

|Col1|Col2|Col3|⬤|Critical|⬤|Medium|⬤|Minor / Informative|
|---|---|---|---|---|---|---|---|---|


-----

