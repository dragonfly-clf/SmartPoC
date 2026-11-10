#### OCTD - Owner Contract Tokens Drain

**Criticality** minor

**Location** contract.sol#L390,396

##### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the manualswap or manualsend
functions.

|Criticality|minor|
|---|---|
|Location|contract.sol#L390,396|

```
  function manualswap() external {
    require(_msgSender() == _developmentAddress || _msgSender() ==
_marketingAddress || _msgSender() == owner());
    uint256 contractBalance = balanceOf(address(this));
    swapTokensForEth(contractBalance);
  }
  function manualsend() external {
    require(_msgSender() == _developmentAddress || _msgSender() ==
_marketingAddress || _msgSender() == owner());
    uint256 contractETHBalance = address(this).balance;
    sendETHToFee(contractETHBalance);
  }

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

