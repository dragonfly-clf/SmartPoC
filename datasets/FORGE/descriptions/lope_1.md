#### ELFM - Exceeds Fees Limit

**Criticality** critical

**Location** contract.sol#L1110,1116

**Status** Unresolved

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setBuyFee and setSellFeefunction
with a high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1110,1116|
|Status|Unresolved|


**function setBuyFee(uint16 liqFee, uint16 team) external onlyOwner {**

**buyFee.projectFee = liqFee;**
**buyFee.teamFee = team;**
**totalBuyFee = buyFee.projectFee + buyFee.teamFee;**
**}**

**function setSellFee(uint16 liqFee, uint16 team) external onlyOwner {**

**sellFee.projectFee = liqFee;**
**sellFee.teamFee = team;**
**totalSellFee = sellFee.projectFee + sellFee.teamFee;**
**}**


##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

