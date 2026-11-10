#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L535, 545

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may convert the contract into a honeypot by increasing the
```
sellFee value.

```
|Criticality|critical|
|---|---|
|Location|contract.sol#L535, 545|

```
function getTotalFee(bool selling) public view returns (uint256) {
    if(launchedAt + 1 >= block.number){ return feeDenominator.sub(1); }
    if(selling){ return sellFee; }
    return buyFee;
  }

```
```
  function takeFee(address sender, address receiver, uint256 amount)
internal returns (uint256) {
    uint256 feeAmount = amount.mul(getTotalFee(receiver ==
pair)).div(feeDenominator);
    _balances[address(this)] = _balances[address(this)].add(feeAmount);
    emit Transfer(sender, address(this), feeAmount);
    return amount.sub(feeAmount);
  }

```

##### Recommendation

The contract could embody a check for not allowing setting the sellFee more than a
reasonable amount. A suggested implementation could check that the maximum
amount should be less than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

