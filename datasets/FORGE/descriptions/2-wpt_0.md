#### ST - Stop Transactions

**Criticality** minor

**Location** contract.sol#L237,L241

##### Description

The contract owner has the authority to stop transactions for all users including the
owner. The owner may take advantage of it by calling the pause function.

|Criticality|minor|
|---|---|
|Location|contract.sol#L237,L241|

```
function transfer(address _to, uint256 _value) public whenNotPaused returns
(bool) {
  return super.transfer(_to, _value);
}
function transferFrom(address _from, address _to, uint256 _value) public
whenNotPaused returns (bool) {
  return super.transferFrom(_from, _to, _value);
}

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

