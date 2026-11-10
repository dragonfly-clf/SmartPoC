#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L351,L321,L307

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L351,L321,L307|

```
maxSwapAmount = newMaxSwapAmount * 10 ** 18
sellFeeMultiplier = multiplier
feeForLiquidity = liquidityFee

```

##### Recommendation

Emit an event for critical parameter changes.