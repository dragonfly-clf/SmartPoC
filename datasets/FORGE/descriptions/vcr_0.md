#### ELFM - Exceed Limit Fees Manipulation

**Criticality** high

**Location** https://bscscan.com/address/0x7596bA3C5d26604470C7a3150CF1105966121b1E
#code#L1030,L1034,L1037

##### Description

The contract owner has the authority to increase fees without limit. The owner may
take advantage of it by calling functions like the setReflectionFee with a high
percentage value.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x7596bA3C5d26604470C7a3150CF1105966121b1E #code#L1030,L1034,L1037|

```
function setReflectionFee(uint256 fee) public onlyOwner {
  _taxFee = fee;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.