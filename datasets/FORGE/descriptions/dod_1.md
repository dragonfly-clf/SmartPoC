#### ELFM - Exceed Limit Fees Manipulation

**Criticality** high

**Location** https://bscscan.com/address/0xe7c8f3d8422c185fd49d9fcc0b72f1d5d8614a44#co
de#L648,L644,L652

##### Description

The contract owner has the authority to increase the fees up to 100%. The owner
may take advantage of it by calling the setDevFeePercent function with a high
percentage value.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0xe7c8f3d8422c185fd49d9fcc0b72f1d5d8614a44#co de#L648,L644,L652|

```
function setDevFeePercent(uint256 devFee) external onlyOwner() {
   _devFee = devFee;
 }

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.