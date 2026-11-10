#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L564,L663

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setFees or the
```
set_sell_multiplier function with a high percentage value.

```
|Criticality|critical|
|---|---|
|Location|contract.sol#L564,L663|

```
function setFees(uint256 _liquidityFee, uint256 _reflectionFee, uint256
_marketingFee, uint256 _teamFee, uint256 _burnFee, uint256 _charityFee, uint256
_feeDenominator) external authorized {
  liquidityFee = _liquidityFee;
  reflectionFee = _reflectionFee;
  marketingFee = _marketingFee;
  teamFee = _teamFee;
  charityFee = _charityFee;
  burnFee = _burnFee;
  totalFee = _liquidityFee + _reflectionFee + _marketingFee + _teamFee +
_burnFee + _charityFee;
  feeDenominator = _feeDenominator;
  require(totalFee < feeDenominator/2, "Fees cannot be more than 50%");
}

```
```
function set_sell_multiplier(uint256 Multiplier) external onlyOwner{
  sellMultiplier = Multiplier;
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

