#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L534

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setTaxes function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L534|

```
function setTaxes(uint256 newMarketingFee) external onlyOwner() {
  _marketingFee = newMarketingFee;
  _totalTax = _marketingFee;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Corrected 10 April 2022

The team has renounced ownership and the threats have been eliminated.


-----

