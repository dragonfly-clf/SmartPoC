#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L801

##### Description

The contract owner has the authority to stop the sales for all users excluding the
owner. The owner may take advantage of it by setting the _totalTaxIfSelling to a
high value. As a result the substitution will underflow and the transaction will revert.

|Criticality|critical|
|---|---|
|Location|contract.sol#L801|

```
else if(isMarketPair[recipient]) {
  feeAmount = amount.mul(_totalTaxIfSelling).div(100);
}
if(feeAmount > 0) {
  _balances[address(this)] = _balances[address(this)].add(feeAmount);
  emit Transfer(sender, address(this), feeAmount);
}
return amount.sub(feeAmount);

```

##### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

