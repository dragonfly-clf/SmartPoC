#### OCTD - Owner Contract Tokens Drain

**Criticality** medium

**Location** contract.sol#L1303

##### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the withdrawRemainingToken function.
The swapTokensAtAmount can also be combined with the withdraw function. The
contract owner can increase the swapTokensAtAmount, so the accumulated fees
will enter in the swap and liquify feature.

|Criticality|medium|
|---|---|
|Location|contract.sol#L1303|

```
function withdrawRemainingToken(address account) public onlyOwner {
  uint256 balance = balanceOf(address(this));
  super._transfer(address(this), account, balance);
}

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

