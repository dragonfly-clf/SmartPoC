#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L787

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setTaxFeePercent function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L787|


function setFee(

uint256 firePitFee_,
uint256 sellLiquidityFee_,
uint256 sellTreasuryFee_,
uint256 sellTedRiskFreeValueFee,
uint256 buyLiquidityFee_,
uint256 buyTreasuryFee_,
uint256 buyTedRiskFreeValueFee_
) external onlyOwner {

firePitFee = firePitFee_;
sellLiquidityFee = sellLiquidityFee_;
sellTreasuryFee = sellTreasuryFee_;
sellTedRiskFreeValueFe = sellTedRiskFreeValueFee;
buyLiquidityFee = buyLiquidityFee_;
buyTreasuryFee = buyTreasuryFee_;
buyTedRiskFreeValueFee = buyTedRiskFreeValueFee_;
}


##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

