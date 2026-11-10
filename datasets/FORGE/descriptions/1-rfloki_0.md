#### ST - Stop Transactions

**Criticality** critical

**Location** https://bscscan.com/address/0x289bf7f7f4d474318f86d2213f51c32360d79fbe#c
ontracts#L611

##### Description

The contract owner has the authority to stop transactions by calling the pause
function.

|Criticality|critical|
|---|---|
|Location|https://bscscan.com/address/0x289bf7f7f4d474318f86d2213f51c32360d79fbe#c ontracts#L611|

```
function _pause() internal virtual whenNotPaused {
  _paused = true;
  emit Paused(_msgSender());
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


-----

