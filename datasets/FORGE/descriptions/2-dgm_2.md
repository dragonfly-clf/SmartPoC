#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L581

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the set_multipliers function with a
high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L581|

```
function set_multipliers(uint256 _buy, uint256 _sell, uint256 _trans) external
onlyOwner{
  sellMultiplier = _sell;
  buyMultiplier = _buy;
  transferMultiplier = _trans;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

