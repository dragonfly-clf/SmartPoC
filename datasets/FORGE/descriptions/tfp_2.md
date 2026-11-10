##### UIF - Unlimited Increase Fees

**Criticality** high

**Location** https://bscscan.com/address/0xb6b0f5dd8b12cf7f4a3ebe7e3e6e97b56b02d0ad#c
ode#L888,L892

###### Description

The contract owner has the authority to increase fees without limit. The owner may
take advantage of it by calling the setTaxFeePercent function with a high
percentage value.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0xb6b0f5dd8b12cf7f4a3ebe7e3e6e97b56b02d0ad#c ode#L888,L892|

```
function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
  _taxFee = taxFee;
}

```

###### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by

temporarily locking the contract or renouncing ownership.