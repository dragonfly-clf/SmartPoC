#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1098,L1094,L1090 and 10 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1098,L1094,L1090 and 10 more|

```
minimumTokensBeforeSwap = _minimumTokensBeforeSwap
marketingDivisor = divisor
_maxTxAmount = maxTxAmount

```
...


##### Recommendation

Emit an event for critical parameter changes.