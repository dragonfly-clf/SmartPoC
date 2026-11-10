##### ELFM - Exceed Limit Fees Manipulation

**Criticality** high

**Location** https://bscscan.com/address/0x1EC8E66A4DdB61475e694e61a4657a65486c1A1
D#code#L1206,L1210,L1214,L1218

###### Description

The contract owner has the authority to increase fees to any amount without
limitations. The owner may take advantage of it by calling the
```
setChartityFeePercent function with a high percentage value.

```
|Criticality|high|
|---|---|
|Location|https://bscscan.com/address/0x1EC8E66A4DdB61475e694e61a4657a65486c1A1 D#code#L1206,L1210,L1214,L1218|

```
function setChartityFeePercent(uint256 marketingFee) external onlyOwner() {
    _marketingFee = marketingFee;
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

