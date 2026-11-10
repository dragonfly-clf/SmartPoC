#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L1189,L1181

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L1189,L1181|

```
numTokensSellToAddToLiquidity = amountTokens * 10 ** _decimals
maxTxAmountBuy = _tTotal / _maxTxAmountBuyPct

```

##### Recommendation

Emit an event for critical parameter changes.