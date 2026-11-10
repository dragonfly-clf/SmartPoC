#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1156,1160,1165,1180,1184

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1156,1160,1165,1180,1184|

```
_maxTxAmount = _tTotal.mul(maxTxPercent).div(10 ** 2)
numTokensSellToAddToLiquidity = newAmount
_BurnFee = newFee
_DevelopmentFee = newFee
_MarketingFees = newFee

```

##### Recommendation

Emit an event for critical parameter changes.


-----

