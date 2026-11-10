#### ELFM - Exceeds Fees Limit


#### Description


The contract has 99% fees, as long as the sniperTaxEnabled variable is true, which is over


the allowed limit of 25%.


#### Recommendation


The contract could embody a check for the maximum acceptable value. The team should


carefully manage the private keys of the owner’s account. We strongly recommend a


powerful security mechanism that will prevent a single user from accessing the contract


admin functions. Some suggestions are:



- Introduce a multi-sign wallet so that many addresses will confirm the action.

- Introduce a governance model where users will vote about the actions.


-----

