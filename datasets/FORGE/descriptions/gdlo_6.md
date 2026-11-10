#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L530,L527,L524 and 1 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L530,L527,L524 and 1 more|

```
_maxTxAmount = _tTotal.mul(maxTxPercent).div(10 ** 3)
_liquidityFee = liquidityFee
_developmentFee = developmentFee

```
...


##### Recommendation

Emit an event for critical parameter changes.