#### LFM - Exceed Limit Fees Manipulation

**Criticality** medium

**Location** https://bscscan.com/address/0x4a7c3e4598fe45096accde1ffaa010336d5fc1d4#co
de#L1165,L1171,L1177

##### Description

The contract owner has the authority to increase total fees to the maximum value of
20%. The owner may take advantage of it by calling the updateMarketingFee
function with a high percentage value like 20.

|Criticality|medium|
|---|---|
|Location|https://bscscan.com/address/0x4a7c3e4598fe45096accde1fafa010336d5fc1d4#co de#L1165,L1171,L1177|

```
function setMarketingFee(uint256 marketingF) external onlyOwner {
  _marketingFee = marketingF;
  totalFeesTax = _taxFee.add(_marketingFee).add(_liquidityFee);
  require(totalFeesTax <= 20, "max 20%");
}

```

##### Recommendation

The contract could decrease the value of total fees to a smaller value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

