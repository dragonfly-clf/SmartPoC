#### ST - Stop Transactions

**Criticality** critical

**Location** contract.sol#L640,492

##### Description

The contract owner has the authority to stop transactions for all users excluding the
owner. The owner may take advantage of it by setting the tradingEnabled to false.

|Criticality|critical|
|---|---|
|Location|contract.sol#L640,492|

```
if (!_isExcludedFromFee[from] && !_isExcludedFromFee[to]) {
  require(tradingEnabled, "Trading not active");
}

```

The contract owner has the authority to stop the sales for all users excluding the
owner. This will cause the contract to operate like a honeypot. The owner may take
advantage of it by setting coolDownTime to a high value

```
if (coolDownEnabled) {
  uint256 timePassed = block.timestamp - _lastSell[from];
  require(timePassed >= coolDownTime, "Cooldown enabled");
  _lastSell[from] = block.timestamp;
}

```

##### Recommendation

The contract could embody a check for not allowing setting the variables less or
more than a reasonable amount.

The team should carefully manage the private keys of the owner’s account. We
strongly recommend a powerful security mechanism that will prevent a single user
from accessing the contract admin functions. That risk can be prevented by
temporarily locking the contract or renouncing ownership.


-----

