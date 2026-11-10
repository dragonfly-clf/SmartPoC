#### ELFM - Exceed Limit Fees Manipulation

**Criticality** high

**Location** https://bscscan.com/address/0xd41c4805a9a3128f9f7a7074da25965371ba50d5#c
ode#L1167,L1171,L1643

##### Description

The contract owner has the authority to increase over the allowed limit of 10%. The
owner may take advantage of it by calling the setTaxFeePercent function with a
high percentage value.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0xd41c4805a9a3128f9f7a7074da25965371ba50d5#c ode#L1167,L1171,L1643|

```
function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
  _taxFee = taxFee;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

