#### ELFM - Exceed Limit Fees Manipulation

**Criticality** medium

**Location** contract.sol#L457

##### Description

The contract owner has the authority to increase transfer fees over the allowed limit
of 25%. The owner may take advantage of it by calling the setMultipliers
function with a high percentage value on transferMultiplier.

|Criticality|medium|
|---|---|
|Location|contract.sol#L457|

```
  function setMultipliers(uint256 _buy, uint256 _sell, uint256 _trans)
external authorized {
    sellMultiplier = _sell;
    buyMultiplier = _buy;
    transferMultiplier = _trans;
    require(totalFee.mul(buyMultiplier).div(100) < 33, "Tax cannot be more
than 32%");
    require(totalFee.mul(sellMultiplier).div(100) < 33, "Tax cannot be more
than 32%");
  }

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

