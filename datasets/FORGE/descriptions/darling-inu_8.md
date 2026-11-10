#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L583,613,719,724

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L583,613,719,724|

```
_maxWalletToken = _tTotal * maxWallPercent_x100 / 10000
_maxTxAmount = _tTotal * maxTxPercent_x100 / 10000
swapTrigger = number_of_transactions
_sellFee = Sell_Fee

```

##### Recommendation

Emit an event for critical parameter changes.


-----

