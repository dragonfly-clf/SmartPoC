#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L1656

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setTaxFeePercent function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1656|


function setFees(

uint256 taxFee,
uint256 liquidityFee,
uint256 marketingFee,
uint256 burnFee
) external onlyOwner {

_taxFee = taxFee;
_liquidityFee = liquidityFee;
_marketingFee = marketingFee;
_burnFee = burnFee;
}


##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

