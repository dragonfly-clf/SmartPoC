#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** https://bscscan.com/address/0xbf5c0dcfd2925fc2f4324cf3e0c9f31c0e36f771#co
de#L846

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setTaxFeePercent function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|https://bscscan.com/address/0xbf5c0dcfd2925fc2f4324cf3e0c9f31c0e36f771#co de#L846|


**function setTaxFeePercent(uint256 taxFee) external onlyOwner() {**

**_taxFee = taxFee;**
**}**


##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

