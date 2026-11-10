#### ELFM - Exceeds Fees Limit


#### Description


The contract owner has the authority to increase over the allowed limit of 25%. The owner


may take advantage of it by calling the `updateFees` function with a high percentage


value.


#### Recommendation


The contract could embody a check for the maximum acceptable value. The team should


carefully manage the private keys of the owner’s account. We strongly recommend a


powerful security mechanism that will prevent a single user from accessing the contract


admin functions. Some suggestions are:



- Introduce a time-locker mechanism with a reasonable delay.

- Introduce a multi-sign wallet so that many addresses will confirm the action.

- Introduce a governance model where users will vote about the actions.

- Renouncing the ownership will eliminate the threats but it is non-reversible.


-----

