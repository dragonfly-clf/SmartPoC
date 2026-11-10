#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L1188

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by setting the fees a high percentage value. There
are a lot of variables that affect the fee variant like the spfai1, spfai2, boepf etc.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1188|

```
function F12__Set_Fees_For_Sells_With_Price_Impact1(
  uint256 project_fee_under_impact1,
  uint256 project_fee_above_impact1,
  uint256 reflections_fee_under_impact1,
  uint256 reflections_fee_above_impact1
  ) external onlySecurityManager {
  //The fees are a percentage number
  require(pi1 != 0, "Cannot set price impact1 fees when impact1 is 0");
  require(project_fee_under_impact1 <= project_fee_above_impact1,
  "The project fee under price impact1 cannot be larger than the fee above
price impact1");
  require(reflections_fee_under_impact1 <= reflections_fee_above_impact1,
  "The reflections fee under price impact1 cannot be larger than the fee above
price impact1");
  ...
  spfui1 = project_fee_under_impact1;
  spfai1 = project_fee_above_impact1;
  srfui1 = reflections_fee_under_impact1;
  srfai1 = reflections_fee_above_impact1;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

