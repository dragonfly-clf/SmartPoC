#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L680

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setFees function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L680|

```
function setFees(uint256 _liquidityFee, uint256 _buybackFee, uint256
_reflectionFee, uint256 _marketingFee, uint256 _feeDenominator) external
authorized {
  liquidityFee = _liquidityFee;
  buybackFee = _buybackFee;
  reflectionFee = _reflectionFee;
  marketingFee = _marketingFee;
  totalFee =
_liquidityFee.add(_buybackFee).add(_reflectionFee).add(_marketingFee);
  feeDenominator = _feeDenominator;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

