#### OCTD - Owner Contract Tokens Drain

**Criticality** minor

**Location** contract.sol#L978

##### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the withdrawAllToTreasury function.

|Criticality|minor|
|---|---|
|Location|contract.sol#L978|

```
  function withdrawAllToTreasury() external swapping onlyOwner {
    uint256 amountToSwap =
_gonBalances[address(this)].div(_gonsPerFragment);
    require( amountToSwap > 0,"There is no AlphaPro token deposited in
token contract");
    address[] memory path = new address[](2);
    path[0] = address(this);
    path[1] = router.WETH();
    router.swapExactTokensForETHSupportingFeeOnTransferTokens(
       amountToSwap,
       0,
       path,
       treasuryReceiver,
       block.timestamp
    );
  }

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

