#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L908,L652,L648 and 2 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L908,L652,L648 and 2 more|

```
numTokensSellToAddToLiquidity = amountToUpdate
_maxTxAmount = maxTxPercent * 10 ** _decimals
_liquidityFee = liquidityFee

```
...


##### Recommendation

Emit an event for critical parameter changes.