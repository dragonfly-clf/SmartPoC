##### ST - Stop Transactions

**Criticality** Medium

**Location** https://bscscan.com/address/0x1EC8E66A4DdB61475e694e61a4657a65486c1A1
D#code#L1226

###### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to a very
small number.

|Criticality|Medium|
|---|---|
|Location|https://bscscan.com/address/0x1EC8E66A4DdB61475e694e61a4657a65486c1A1 D#code#L1226|

```
 function setMaxTxAmount(uint256 maxTxAmount, uint256 decimal) external
onlyOwner() {
    require(maxTxAmount > 0, "Cannot set transaction amount as zero");
    _maxTxAmount = maxTxAmount * 10**decimal;
  }

```

###### Recommendation

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.