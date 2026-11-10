#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L626,L622,L610 and 3 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L626,L622,L610 and 3 more|

```
minimumTokensBeforeSwap = newLimit
_walletMax = newLimit
_maxTxAmount = maxTxAmount

```
...


##### Recommendation

Emit an event for critical parameter changes.