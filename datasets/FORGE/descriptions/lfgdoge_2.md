#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** minor

**Location** contract.sol#L671

##### Description

The contract owner has the authority to transfer funds to the team wallet. These
funds have been accumulated from fees collected from the contract and sold for
bnb.

|Criticality|minor|
|---|---|
|Location|contract.sol#L671|

```
function swapAndLiquify(uint256 tAmount) private lockTheSwap {
  swapTokensForEth(tAmount);
  uint256 amountReceived = address(this).balance;
  if(amountReceived > 0)
    transferToAddressETH(marketingWalletAddress, amountReceived);
}

```

##### Recommendation

The contract could embody a check for the maximum amount of tokens that can be
sold in one transaction.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Corrected 10 April 2022

The team has renounced ownership and the threats have been eliminated.


-----

