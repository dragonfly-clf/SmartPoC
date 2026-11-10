#### ELFM - Exceeds Fees Limit

**Criticality** critical

**Location** contract.sol#L323

**Status** Unresolved

##### Description

The contract owner has the authority to increase over the allowed limit of 25%. The
owner may take advantage of it by setting the kb variable to a very low value, which
will lead to _funTransfer being called and the user will be taxed with 90% fee.

|Criticality|critical|
|---|---|
|Location|contract.sol#L323|
|Status|Unresolved|

```
function _funTransfer(address sender, address recipient, uint256 tAmount)
private {
  _balances[sender] = _balances[sender] - tAmount;
  uint256 feeAmount = tAmount * 90 / 100;
  _takeTransfer(sender, fundAddress, feeAmount);
  _takeTransfer(sender, recipient, tAmount - feeAmount);
}

```

##### Recommendation

The contract should lower the tax fee to at least the max allowed limit, which is
25%.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

