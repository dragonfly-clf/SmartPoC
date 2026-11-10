#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L538,542,550

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L538,542,550|

```
coolDownTime = _timeInSeconds * 1
swapTokensAtAmount = amount * 10 ** _decimals
maxTxAmount = amount * 10 ** _decimals

```

##### Recommendation

Emit an event for critical parameter changes.


-----

