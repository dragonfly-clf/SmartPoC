#### ELFM - Exceeds Fees Limit

**Criticality** minor / informative

**Location** contract.sol#L390

**Status** Unresolved

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setSellTaxes function with a high
percentage value.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L390|
|Status|Unresolved|


function setSellTaxes(

uint256 _rfi,
uint256 _marketing,
uint256 _liquidity,
uint256 _buyback
) public onlyOwner {

sellTaxes = Taxes(_rfi, _marketing, _liquidity, _buyback);
**require((_rfi + _marketing + _liquidity + _buyback) <= 30, "Must keep fees at 30% or**
**less");**

emit FeesChanged();
}


##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

