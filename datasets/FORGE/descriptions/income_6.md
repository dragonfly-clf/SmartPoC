#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1952,L1857,L1853 and 1 more

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1952,L1857,L1853 and 1 more|

```
swapTokensAtAmount = _newAmount
maxSellTransactionAmount = _maxSellTxAmount
extraFeeOnSell = _extraFeeOnSell

```
...


##### Recommendation

Emit an event for critical parameter changes.