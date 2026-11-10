#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** https://bscscan.com/address/0xaef0a177c8c329cbc8508292bb7e06c00786bbfc
#L1145

**Status** Multi-Sign

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setSellFee function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|https://bscscan.com/address/0xaef0a177c8c329cbc8508292bb7e06c00786bbfc #L1145|
|Status|Multi-Sign|

```
  function setSellFee(uint16 liq, uint16 market, uint16 reward, uint16 tax)
external onlyOwner {
    sellFee.liquidityFee = liq;
    sellFee.marketingFee = market;
    sellFee.buybackFee = reward;
    sellFee.taxFee = tax;
  }

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

