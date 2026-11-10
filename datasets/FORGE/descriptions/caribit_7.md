#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1825,L1428,L1423 and 3 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1825,L1428,L1423 and 3 more|

```
lastProcessedIndex = index
buyBackAndBurnFee = value
marketingFee = value

```
...


##### Recommendation

Emit an event for critical parameter changes.