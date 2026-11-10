#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L925,L936

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setSellFees or the setBuyFees
function with a high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L925,L936|

```
function setSellFees(uint256 _liquidityFeeSell, uint256 _buybackFeeSell, uint256
_reflectionFeeSell, uint256 _marketingFeeSell, uint256 _devFeeSell, uint256
_feeDenominator) external authorized {
  liquidityFeeSell = _liquidityFeeSell;
  buybackFeeSell = _buybackFeeSell;
  reflectionFeeSell = _reflectionFeeSell;
  marketingFeeSell = _marketingFeeSell;
  devFeeSell = _devFeeSell;
  totalFeeSell =
_liquidityFeeSell.add(_buybackFeeSell).add(_reflectionFeeSell).add(_marketingFee
Sell).add(_devFeeSell);
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

