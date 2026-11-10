#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** high

**Location** https://bscscan.com/address/0xd41c4805a9a3128f9f7a7074da25965371ba50d5#c
ode#L1443

##### Description

The contract owner has the authority to transfer funds without limit to the team
wallet. These funds have been swiped from the swap & liquify feature. The owner
may take advantage of it by setting a high fee to the _marketingLiquifyFee
variable.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0xd41c4805a9a3128f9f7a7074da25965371ba50d5#c ode#L1443|

```
uint256 TokensForMarketing = contractTokenBalance
 .mul(_marketingLiquifyFee)
 .div(_marketingLiquifyFee.add(_liquidityFee));
TokensForLiquidity = contractTokenBalance.sub(TokensForMarketing);
swapTokensForBnb(TokensForMarketing, marketingWallet);

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.