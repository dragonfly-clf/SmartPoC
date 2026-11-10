##### ELFM - Exceed Limit Fees Manipulation

**Criticality** high

**Location** https://bscscan.com/address/0xcc21ec2c6867ac6efd9ce158996ff47ab5743b2d#co
de#L887,L821

###### Description

The contract owner has the authority to increase fees without limit. The owner may
take advantage of it by calling the setTaxFeePercent function with a high percentage
value.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0xcc21ec2c6867ac6efd9ce158996f4f7ab5743b2d#co de#L887,L821|

```
function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
  _taxFee = taxFee;
}

```

###### Recommendation

The contract could decrease the value of MAX_FEE_RATE to a value less than 10.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

