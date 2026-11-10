#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L1184

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setExtraSellFee function with a
high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1184|

```
function setExtraSellFee(uint256 value) external onlyOwner{
  extraSellFee = value;
  uint256 totalSellFees = rewardFees + liquidityFee + marketingFee;
  require(totalSellFees <= 25, "ELONTICKER: Maximum allowed fees are 25%");
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

