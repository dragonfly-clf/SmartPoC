#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L952,L924,L914 and 4 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L952,L924,L914 and 4 more|

```
deadBlocks = _deadBlocks
targetLiquidity = _target
swapThreshold = _swapThreshold

```
...


##### Recommendation

Emit an event for critical parameter changes.