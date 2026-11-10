#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1422,1426,1430,1434,1478

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1422,1426,1430,1434,1478|

```
minHolder = _minHolder
sellMarketingFeeRate = _fee
buyMarketingFeeRate = _fee
sellRewardFeeRate = _fee
buyRewardFeeRate = _fee

```

##### Recommendation

Emit an event for critical parameter changes.


-----

