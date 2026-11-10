#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L609,631,637,643,648

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L609,631,637,643,648|

```
targetLiquidity = _target
swapThreshold = _amount
liquidityFeeShare = _liquidityFeeShare
buyFee = _buyFee
maxTxAmount = amount

```

##### Recommendation

Emit an event for critical parameter changes.


-----

