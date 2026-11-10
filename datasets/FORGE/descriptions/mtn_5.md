#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L943,L939,L934 and 3 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L943,L939,L934 and 3 more|

```
buyBackUpperLimit = buyBackLimit
minimumTokensBeforeSwap = _minimumTokensBeforeSwap
marketingFee = _marketingFee

```
...


##### Recommendation

Emit an event for critical parameter changes.