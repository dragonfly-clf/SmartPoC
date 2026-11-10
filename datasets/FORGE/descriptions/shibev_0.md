#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** https://bscscan.com/address/0x2629eb2edef0f45b9f250f4ec934bbc8628dbaca
#code#L1576

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setBuyFees function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|https://bscscan.com/address/0x2629eb2edef0f45b9f250f4ec934bbc8628dbaca #code#L1576|

```
function setBuyFees(
    uint16 _reward,
    uint16 _marketing,
    uint16 _burn
  ) external onlyOwner {
    buyFee.reward = _reward;
    buyFee.marketing = _marketing;
    buyFee.burn = _burn;
    totalBuyFee = buyFee.reward + buyFee.marketing;
  }

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

