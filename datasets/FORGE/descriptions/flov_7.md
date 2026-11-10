#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1474,L1370,L1365 and 2 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1474,L1370,L1365 and 2 more|

```
_maxTxAmount = maxTxAmount
marketingFee = _marketingFee
liquidityFee = value

```
...


##### Recommendation

Emit an event for critical parameter changes.