#### ST - Stop Transactions

**Criticality** medium

**Location** contract.sol#L529

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _feeDominator to zero.

|Criticality|medium|
|---|---|
|Location|contract.sol#L529|

```
 function takeFee(address sender, address receiver, uint256 amount) internal
returns (uint256) {
    uint256 feeAmount = amount.mul(getTotalFee(receiver ==
pair)).div(feeDenominator);
    _balances[address(this)] = _balances[address(this)].add(feeAmount);
    emit Transfer(sender, address(this), feeAmount);
    return amount.sub(feeAmount);
  }

```

##### Recommendation

The contract could embody a check for not allowing setting the feeDominator less
than a reasonable amount. A suggested implementation could check that the
minimum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

