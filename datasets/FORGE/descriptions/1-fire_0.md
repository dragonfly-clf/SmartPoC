#### ELFM - Exceed Limit Fees Manipulation

**Criticality** high

**Location** https://bscscan.com/address/0x7fA6f63B11CC1af508cD19Ba823853d6aaCd9d65#
code#L643,L647,L639

##### Description

The contract owner has the authority to increase fees to any value without
limitations. The owner may take advantage of it by calling the setDevFeePercent
function with a high percentage value.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x7fA6f63B11CC1af508cD19Ba823853d6aaCd9d65# code#L643,L647,L639|

```
function setDevFeePercent(uint256 devFee) external onlyOwner() {
    _devFee = devFee;
  }

```

##### Recommendation

The contract should have a check to not let total fees increase more than 25%.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

