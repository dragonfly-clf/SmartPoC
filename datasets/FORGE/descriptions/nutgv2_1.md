#### ELFM - Exceed Limit Fees Manipulation

**Criticality** minor

**Location** contract.sol#L396

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setSellTaxes function with 30
percentage value.

|Criticality|minor|
|---|---|
|Location|contract.sol#L396|

```
  function setSellTaxes(
    uint256 _rfi,
    uint256 _marketing,
    uint256 _liquidity,
    uint256 _dev,
    uint256 _utility,
    uint256 _burn
  ) public onlyOwner {
    sellTaxes = Taxes(_rfi, _marketing, _liquidity, _dev, _utility, _burn);
    require((_rfi + _marketing + _utility + _liquidity + _dev + _burn) <=
30, "Must keep fees at 30% or less");
    emit FeesChanged();
  }

```

##### Recommendation

The contract could have a lower limit on fees.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

