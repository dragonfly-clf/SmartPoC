#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L304

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setTaxes function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L304|

```
function setTaxes(uint256 _rfi, uint256 _dev, uint256 _liquidity, uint256 _burn)
public onlyOwner {
  taxes.rfi = _rfi;
  taxes.dev = _dev;
  taxes.liquidity = _liquidity;
  taxes.burn = _burn;
  emit FeesChanged();
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

