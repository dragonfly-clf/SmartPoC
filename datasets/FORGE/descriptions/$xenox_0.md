#### ELFM - Exceed Limit Fees Manipulation

**Criticality** high

**Location** https://bscscan.com/address/0xcb9fd3784e9f369c4ad3bd4cb0d3a21acbf23a51#c
ode#L1083,L1087,L1091,L1095,L1099,L1103

##### Description

The contract owner has the authority to increase fees to any value without
limitations. This can be used in a malicious way and disturb the holders’
transactions.

|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0xcb9fd3784e9f369c4ad3bd4cb0d3a21acbf23a51#c ode#L1083,L1087,L1091,L1095,L1099,L1103|

```
function setSelldevFeePercent(uint256 devFee) external onlyOwner() {
   _selldevFee = devFee;
 }

```

##### Recommendation

The contract could have a limitation to require the fees to not exceed a value more
than 10%.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

