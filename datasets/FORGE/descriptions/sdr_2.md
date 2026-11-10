#### ST - Stop Transactions

**Criticality** medium

**Location** https://bscscan.com/address/0x6aece5a72093bc46ff7302895f5e9d0bd1346bfa
#code#L1153

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the _maxTxAmount to zero
and excluding himself.

|Criticality|medium|
|---|---|
|Location|https://bscscan.com/address/0x6aece5a72093bc46f7f302895f5e9d0bd1346bfa #code#L1153|

```
  if (_isExcludedFromMaxTx[from] == false && _isExcludedFromMaxTx[to] ==
false) {
       require(amount <= _maxTxAmount, "Transfer amount exceeds the
maxTxAmount.");
    }

```

##### Recommendation

The contract could embody a check for not allowing setting the _maxTxAmount less
than a reasonable amount. A suggested implementation could check that the
maximum amount should be more than a fixed percentage of the total supply.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.