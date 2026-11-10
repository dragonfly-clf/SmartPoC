#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L583

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the _set_Fees function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L583|

```
  function _set_Fees(uint256 Buy_Fee, uint256 Sell_Fee) external onlyOwner()
{
    require((Buy_Fee + Sell_Fee) <= maxPossibleFee, "Fee is too high!");
    _sellFee = Sell_Fee;
    _buyFee = Buy_Fee;
  }

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

