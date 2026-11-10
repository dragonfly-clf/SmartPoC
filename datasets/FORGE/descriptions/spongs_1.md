#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L1520

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the updateFees function with a high
percentage value on a parameter like the liquidityFee.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1520|

```
function updateFees(uint256 bnbRewardPerc, uint256 liquidityPerc, uint256
operationsPerc, uint256 buyBackPerc) external onlyOwner {
  require (operationsPerc.add(buyBackPerc) <= liquidityPerc, "SPONGS:
updateFees:: Liquidity Perc must be equal to or higher than operations and
buyback combined.");
  emit FeesUpdated(bnbRewardPerc, liquidityPerc, operationsPerc, buyBackPerc);
  BNBRewardsFee = bnbRewardPerc;
  liquidityFee = liquidityPerc;
  operationsFee = operationsPerc;
  buyBackFee= buyBackPerc;
  totalFees = BNBRewardsFee.add(liquidityFee);
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

