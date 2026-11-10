#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1751,L1608,L1584 and 1 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1751,L1608,L1584 and 1 more|

```
maxTxAmount = amount
swapTokensAtAmount = amount
totalSellFee = sellFee.reward + sellFee.marketing

```
...


##### Recommendation

Emit an event for critical parameter changes.