#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1223,L1219,L1215 and 3 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1223,L1219,L1215 and 3 more|

```
_maxTxAmount = maxTxAmount * 10 ** decimal
numTokensSellToAddToLiquidity = newAmt * 10 ** decimal
_burnFee = burnFee

```
...


##### Recommendation

Emit an event for critical parameter changes.