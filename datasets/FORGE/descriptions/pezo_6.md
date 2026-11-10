#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L244,655,681,695,700

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L244,655,681,695,700|

```
targetLiquidity = _target
swapThreshold = _amount
liquidityFee = _liquidityFee

```
...


##### Recommendation

Emit an event for critical parameter changes.