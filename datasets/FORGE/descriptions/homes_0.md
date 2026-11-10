#### ELFM - Exceed Limit Fees Manipulation

**Criticality** high

**Location** https://polygonscan.com/address/0xb7ba576c526cfafc77e47b4959eb6c67504d54
25#code#L983,L987

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setMarketingFeePercent function
with a high percentage value.

|Criticality|high|
|---|---|
|Location|https://polygonscan.com/address/0xb7ba576c526cfafc77e47b4959eb6c67504d54 25#code#L983,L987|

```
function setMarketingFeePercent(uint256 marketingFee) external onlyOwner() {
  _marketingFee = marketingFee;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

