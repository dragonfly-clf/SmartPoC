#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L210,462,466,581,588,596,682,700,705

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L210,462,466,581,588,596,682,700,705|

```
targetLiquidity = _target
swapThreshold = _amount
liquidityFee = _liquidityFee
launchedAt = _launchblock
deadBlocks = _deadBlocks
sellMultiplier = _sell
_maxTxAmount = amount
_maxTxAmount = (_totalSupply * maxTXPercentage_base1000) / 1000
minPeriod = _minPeriod

```

##### Recommendation

Emit an event for critical parameter changes.


-----

