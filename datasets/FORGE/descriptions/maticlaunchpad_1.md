#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L956,960

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setTaxFeePercent or
```
setLiquidityFeePercent function with a high percentage value.

```
|Criticality|critical|
|---|---|
|Location|contract.sol#L956,960|

```
function setTaxFeePercent(uint256 taxFee) external onlyOwner() {
  _taxFee = taxFee;
}
function setLiquidityFeePercent(uint256 liquidityFee) external onlyOwner() {
  _liquidityFee = liquidityFee;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

