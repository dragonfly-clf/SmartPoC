#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L245,628,638,642,657,680,694,699

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L245,628,638,642,657,680,694,699|

```
targetLiquidity = _target
swapThreshold = _amount
liquidityFee = _liquidityFee
_maxTxAmount = amount
buybackMultiplierNumerator = numerator
deadBlocks = _deadBlocks
autoBuybackCap = _cap
minPeriod = _minPeriod

```

##### Recommendation

Emit an event for critical parameter changes.


-----

