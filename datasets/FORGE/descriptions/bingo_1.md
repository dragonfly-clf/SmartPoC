#### OCTD - Owner Contract Tokens Drain

**Criticality** minor

**Location** contract.sol#L534

##### Description

The contract owner has the authority to claim all the balance of the contract. The
owner may take advantage of it by calling the rescueToken function.

|Criticality|minor|
|---|---|
|Location|contract.sol#L534|

```
 function rescueToken(address tokenAddress, uint256 tokens) public onlyOwner
returns (bool success) {
    return IERC20(tokenAddress).transfer(msg.sender, tokens);
  }

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

