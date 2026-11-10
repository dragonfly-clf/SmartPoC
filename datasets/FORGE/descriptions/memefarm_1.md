#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L301,L309

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setBuyTaxes and setAllTaxes function
with a high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L301,L309|


function setBuyTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newTeamTax)
external onlyOwner() {

_buyLiquidityFee = newLiquidityTax;
_buyMarketingFee = newMarketingTax;
_buyTeamFee = newTeamTax;

_totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee).add(_buyTeamFee);
}

function setAllTaxes(uint256 newLiquidityTax, uint256 newMarketingTax, uint256 newTeamTax)
external onlyOwner() {

_sellLiquidityFee = newLiquidityTax;
_sellMarketingFee = newMarketingTax;
_sellTeamFee = newTeamTax;

_totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee).add(_sellTeamFee);
}


##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

