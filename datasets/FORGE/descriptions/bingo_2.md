#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L550, 557

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setBuyTaxes and the setSelTaxes
functions with a high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L550, 557|

```
function setBuyTaxes(uint256 newLiquidityTax, uint256 newMarketingTax)
external onlyOwner() {
    _buyLiquidityFee = newLiquidityTax;
    _buyMarketingFee = newMarketingTax;
    _totalTaxIfBuying = _buyLiquidityFee.add(_buyMarketingFee);
  }

```
```
function setSelTaxes(uint256 newLiquidityTax, uint256 newMarketingTax)
external onlyOwner() {
    _sellLiquidityFee = newLiquidityTax;
    _sellMarketingFee = newMarketingTax;
    _totalTaxIfSelling = _sellLiquidityFee.add(_sellMarketingFee);
  }

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

