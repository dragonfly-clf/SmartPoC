#### OCTD - Owner Contract Tokens Drain

**Criticality** minor

**Location** contract.sol#L690

##### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the rescueAnyBEP20Tokens function.

|Criticality|minor|
|---|---|
|Location|contract.sol#L690|

```
function rescueAnyBEP20Tokens(address _tokenAddr, address _to, uint _amount)
public onlyOwner {
    IERC20(_tokenAddr).transfer(_to, _amount);
  }

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

