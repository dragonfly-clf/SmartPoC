#### ELFM - Exceed Limit Fees Manipulation

**Criticality** critical

**Location** contract.sol#L398,410

**Status** Resolved

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by calling the setTaxes function with a high
percentage value.

|Criticality|critical|
|---|---|
|Location|contract.sol#L398,410|
|Status|Resolved|

```
function setTaxes(
   uint256 _rfi,
   uint256 _charity,
   uint256 _liquidity,
   uint256 _utility,
   uint256 _operation,
   uint256 _burn
 ) public onlyOwner {
   taxes = Taxes(_rfi, _charity, _liquidity, _utility, _operation, _burn);
   emit FeesChanged();
 }

```

##### Recommendation

The contract could embody a check for the maximum acceptable value.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.

##### Corrected 05 April 2022

The owner has renounced contract ownership and the threats have been eliminated.


-----

