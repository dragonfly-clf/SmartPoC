#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L984,988,997

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L984,988,997|

```
liquidityFee = _liquidityFee
rebaseFrequency = _rebaseFrequency
rewardYield = _rewardYield

```

##### Recommendation

Emit an event for critical parameter changes.


-----

