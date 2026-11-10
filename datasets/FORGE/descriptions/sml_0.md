#### ST - Stops Transactions

**Criticality** medium

**Location** contract.sol#L1129

**Status** Unresolved

##### Description

The contract owner has the authority to stop the transactions for all users excluding
the owner. The owner may take advantage of it by setting the maxTxPercent to zero.

|Criticality|medium|
|---|---|
|Location|contract.sol#L1129|
|Status|Unresolved|

```
function setMaxTxPercent(uint256 maxTxPercent) external onlyOwner() {
  _maxTxAmount = _tTotal.mul(maxTxPercent).div(10**2);
}
...
require(amount <= _maxTxAmount, "Transfer amount exceeds the maxTxAmount.");

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

