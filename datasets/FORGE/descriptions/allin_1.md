#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L636

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setFees function with high
percentage values.

|Criticality|critical|
|---|---|
|Location|contract.sol#L636|

```
  function setFees(uint256 _liquidityFee, uint256 _buybackFee, uint256
_reflectionFee, uint256 _marketingdevelopmentFee, uint256 _feeDenominator)
external authorized {
    liquidityFee = _liquidityFee;
    buybackFee = _buybackFee;
    reflectionFee = _reflectionFee;
    marketingdevelopmentFee = _marketingdevelopmentFee;
    totalFee =
_liquidityFee.add(_buybackFee).add(_reflectionFee).add(_marketingdevelopmentFee
);
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

