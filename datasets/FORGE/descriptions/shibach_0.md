##### ELFM - Exceed Limit Fees Manipulation

**Criticality** high

**Location** https://bscscan.com/address/0x9F13F58bFb28Bd84e8C885C47C34D9f648903ea1
#code#L527,L530,L533

###### Description

The contract owner has the authority to increase fees to any amount without
limitations. The owner may take advantage of it by calling the
```
setDevelopmentFeePercent function with a high percentage value.

```
|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x9F13F58bFb28Bd84e8C885C47C34D9f648903ea1 #code#L527,L530,L533|

```
  function setDevelopmentFeePercent(uint256 developmentFee) external
onlyOwner() {
    _developmentFee = developmentFee;
  }

```

###### Recommendation

The contract’s functions that can update fees should have limitations to what the
fees can be up to a total of 10%.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

