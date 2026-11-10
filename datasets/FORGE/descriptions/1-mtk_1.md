#### LTW - Liquidity to Team Wallet

**Criticality** high

**Location** https://bscscan.com/address/0x4a7c3e4598fe45096accde1ffaa010336d5fc1d4#co
de#L1000

##### Description

The contract owner has the authority to transfer funds to the team wallet. These
funds have been swapped from the swap & liquify feature. The owner may take
advantage of it by setting a high fee to the marketingFee variable. With the current
fees, the dev wallet would drain more than 65% of the token’s liquidity everytime.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x4a7c3e4598fe45096accde1fafa010336d5fc1d4#co de#L1000|

```
     if (_marketingFee > 0) {
swapAndSendMarketing(contractTokenBalance.mul(_marketingFee).div(_liquidityFee.a
dd(_marketingFee)));
       }

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.