##### ULTW - Unlimited Liquidity to Team Wallet

###### Criticality high

 Location https://bscscan.com/address/0xb6b0f5dd8b12cf7f4a3ebe7e3e6e97b56b02d0ad#c ode#L2890

 Description

 The contract owner has the authority to transfer funds without limit to the team wallet. These funds have been swiped from the swap & liquify feature. The owner may take advantage of it by setting a high fee to the marketingFee variable.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0xb6b0f5dd8b12cf7f4a3ebe7e3e6e97b56b02d0ad#c ode#L2890|

```
contractTokenBalance * (marketingFee/totalFees) =
contractTokenBalance * (100/100) =
contractTokenBalance

```
```
uint256 marketingTokens = contractTokenBalance.mul(marketingFee).div(totalFees);
swapAndSendToFee(marketingTokens);

```

###### Recommendation

 The contract could embody a check for the maximum acceptable value.

 The team should carefully manage the private keys of the owner’s account. We strongly recommend a powerful security mechanism that will prevent a single user from accessing the contract admin functions. That risk can be prevented by

 temporarily locking the contract or renouncing ownership.