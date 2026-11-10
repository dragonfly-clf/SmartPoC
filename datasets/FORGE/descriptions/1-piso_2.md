#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L362,367

**Status** Resolved

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setTaxes, setSellTaxes function with a
high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L362,367|
|Status|Resolved|


function setTaxes(uint256 _rfi, uint256 _marketing, uint256 _liquidity, uint256 _dev, uint256
_buyback) public onlyOwner {

taxes = Taxes(_rfi,_marketing,_liquidity,_dev,_buyback);

emit FeesChanged();
}

function setSellTaxes(uint256 _rfi, uint256 _marketing, uint256 _liquidity, uint256 _dev, uint256
_buyback) public onlyOwner {

sellTaxes = Taxes(_rfi,_marketing,_liquidity,_dev,_buyback);

emit FeesChanged();
}


##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Updated 03 August 2022

The team has renounced ownership and resolved the issues.


-----

