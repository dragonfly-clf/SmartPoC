#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** medium

**Location** https://bscscan.com/address/0xbf5c0dcfd2925fc2f4324cf3e0c9f31c0e36f771#co
de#L646

##### Description

The contract transfers funds to the team wallet. These funds have been swiped from
the swap & liquify feature. The owner may take advantage of it by setting a high fee
to the _feeRate variable.

|Criticality|medium|
|---|---|
|Location|https://bscscan.com/address/0xbf5c0dcfd2925fc2f4324cf3e0c9f31c0e36f771#co de#L646|

```
function swapTokens(uint256 contractTokenBalance) private lockTheSwap {
  swapTokensForEth(contractTokenBalance);
  //Send to Marketing address
  uint256 contractETHBalance = address(this).balance;
  if(contractETHBalance > 0) {
    sendETHToFee(address(this).balance);
  }
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

