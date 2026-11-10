#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L1845

**Status** Resolved

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setFee function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1845|
|Status|Resolved|

```
function setFee(uint256 _bnbRewardFee, uint256 _liquidityFee, uint256
_marketingFee) public onlyOwner {
  BNBRewardsFee = _bnbRewardFee;
  liquidityFee = _liquidityFee;
  marketingFee = _marketingFee;
  totalFees = BNBRewardsFee.add(liquidityFee).add(marketingFee); // total fee
transfer and buy
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Updated 15 June 2022

The team has renounced ownership and resolved the issues.


-----

