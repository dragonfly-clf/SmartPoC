#### OCTD - Owner Contract Tokens Drain

**Criticality** minor

**Location** contract.sol#L1735

##### Description

The contract owner has the authority to claim all the tokens of the contract. These
tokens have been accumulated from the fees tax. The owner may take advantage of
it by calling the withdraw function.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1735|

```
function withdraw(address _token, uint256 _amount) external {
  require(msg.sender == safeManager);
  IERC20(_token).transfer(safeManager, _amount);
}

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

