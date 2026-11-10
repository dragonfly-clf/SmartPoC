##### UIF - Unlimited Increase Fees

**Criticality** high

**Location** https://bscscan.com/address/0x2df0c13487efdf4eb7f6c042273b7aca781b29a0#co
de#L1008,L1014,L1020

**Status** Resolved

###### Description

The contract owner has the authority to increase fees without limit. The owner may
take advantage of it by calling the setTaxFee function with a high percentage value.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x2df0c13487efdf4eb7f6c042273b7aca781b29a0#co de#L1008,L1014,L1020|
|Status|Resolved|

```
function setTaxFee(uint256 _newTaxFee) public onlyOwner {
  require(_newTaxFee != 0, "newTaxFee can not be Zero amount");
  _taxFee = _newTaxFee;
  _previousTaxFee = _taxFee;
}

```

###### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

###### Resolved

The team locked the contract and has no longer access to owner functions. The
contract will be locked until 10 January 2022
https://bscscan.com/tx/0x7bd85dd8c8c7c77a52d0e49c10a7044c5a9296606b8383
d85f30a785d897da69