#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1216,1224,1228,1249,1257

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1216,1224,1228,1249,1257|

```
sellTokenRewardsFee = rewardsFee
buyTokenRewardsFee = rewardsFee
TwentyFourhours = _time
txfee = _value
swapTokensAtAmount = amount

```

##### Recommendation

Emit an event for critical parameter changes.


-----

