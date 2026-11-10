#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L807,812,816,821,832,869,874,889,893

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L807,812,816,821,832,869,874,889,893|

```
maxSellTransactionAmount = _maxTxn
nextRebase = _nextRebase
rewardYield = _rewardYield
rebaseFrequency = _rebaseFrequency
liquidityFee = _liquidityFee
gonSwapThreshold = TOTAL_GONS.div(_denom).mul(_num)
targetLiquidity = target
TwentyFourhours = _time
maxSellAmount = _maxSellAmount

```

##### Recommendation

Emit an event for critical parameter changes.


-----

