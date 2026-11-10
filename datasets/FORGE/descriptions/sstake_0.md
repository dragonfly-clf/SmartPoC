#### ULTW - Unlimited Liquidity to Team Wallet

**Criticality** minor

**Location** contract.sol#L732

##### Description

The contract owner has the authority to transfer funds to the team wallet. These
funds have been accumulated from fees collected from the contract. The owner
may take advantage of it by calling the withdrawAllTooperational function.

|Criticality|minor|
|---|---|
|Location|contract.sol#L732|

```
function withdrawAllTooperational() external swapping onlyOwner {
  uint256 amountToSwap = _gonBalances[address(this)].div(_gonsPerFragment);
  require( amountToSwap > 0,"There is no SStake token deposited in token
contract");
  address[] memory path = new address[](2);
  path[0] = address(this);
  path[1] = router.WETH();
  router.swapExactTokensForETHSupportingFeeOnTransferTokens(
    amountToSwap,
    0,
    path,
    operationalReceiver,
    block.timestamp
  );
}

```

##### Recommendation

The contract could embody a check for the maximum amount of funds that can be
swapped. Since a huge amount may violate the token’s price.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

