#### ELFM - Exceed Limit Fees Manipulation

**Criticality** high

**Location** https://bscscan.com/address/0x8d37cA3285a93e7E2bD50747a57c87EBf738c395#
code#L829,L833,L837,L841,L845

##### Description

The contract owner has the authority to increase over the allowed limit of 10%. The
owner may take advantage of it by calling the setTaxFee function with a high
percentage value.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x8d37cA3285a93e7E2bD50747a57c87EBf738c395# code#L829,L833,L837,L841,L845|

```
function setTaxFee(uint256 fee) public onlyOwner {
  _taxFee = fee;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.