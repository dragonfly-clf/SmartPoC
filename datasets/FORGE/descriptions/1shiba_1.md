##### LTW - Liquidity to Team Wallet

**Criticality** high

**Location** https://bscscan.com/address/0xcc21ec2c6867ac6efd9ce158996ff47ab5743b2d#co
de#L1048

###### Description

The contract transfers a lot of funds to the team wallet. These funds have been
swapped from the swap & liquify feature.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0xcc21ec2c6867ac6efd9ce158996f4f7ab5743b2d#co de#L1048|

```
// 1/2 balance is sent to the marketing wallet, 1/2 is added to the liquidity
pool
uint256 marketingTokenBalance = contractTokenBalance.div(2);
uint256 liquidityTokenBalance = contractTokenBalance.sub(marketingTokenBalance);

```

###### Recommendation

The contract could embody a small percentage and send a small amount of funds
to the team wallet, the maximum recommended value is usually 4%.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

