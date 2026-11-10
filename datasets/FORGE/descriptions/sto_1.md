#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L1

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setTaxesFeePercent and setSellTaxes
functions with a high percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L1|

```
function setTaxes(uint256 _marketing, uint256 _liquidity, uint256 _burn)
external onlyOwner{
  taxes = Taxes(_marketing, _liquidity, _burn);
}

```
```
function setSellTaxes(uint256 _marketing, uint256 _liquidity, uint256 _burn)
external onlyOwner{
  sellTaxes = Taxes(_marketing, _liquidity, _burn);
}

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

