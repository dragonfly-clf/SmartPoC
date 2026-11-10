#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L242,648,658,673,696,710 and 1 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L242,648,658,673,696,710 and 1 more|

```
targetLiquidity = _target
swapThreshold = _amount
liquidityFee = _liquidityFee

```
...


##### Recommendation

Emit an event for critical parameter changes.


-----

