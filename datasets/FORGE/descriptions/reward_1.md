#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L997

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setFees function with a high
percentage value to the _sellFeef variable.

|Criticality|critical|
|---|---|
|Location|contract.sol#L997|

```
function setFees(
  uint256 _liquidityFee,
  uint256 _treasuryFee,
  uint256 _feeDenominator,
  uint256 _firePitFee,
  uint256 _sellFeel,
  uint256 _sellFeet,
  uint256 _sellFeef,
  uint256 _riskFreeValueFee
) external onlyOwner {
  liquidityFee = _liquidityFee;
  treasuryFee = _treasuryFee;
  firePitFee = _firePitFee;
  sellFeel = _sellFeel;
  sellFeet = _sellFeet;
  sellFeef = _sellFeef;
  riskFreeValueFee = _riskFreeValueFee;
  totalFee =
liquidityFee.add(treasuryFee).add(firePitFee).add(riskFreeValueFee);
  feeDenominator = _feeDenominator;
  require(totalFee < feeDenominator / 4);
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

