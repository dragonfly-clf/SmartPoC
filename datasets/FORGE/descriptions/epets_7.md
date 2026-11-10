#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L347,457,476,481

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L347,457,476,481|

```
targetLiquidity = _target
swapThreshold = _amount
liquidityFee = _liquidityFee
sellMultiplier = _sell

```

##### Recommendation

Emit an event for critical parameter changes.


-----

