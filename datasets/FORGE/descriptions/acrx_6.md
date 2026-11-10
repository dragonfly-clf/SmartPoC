#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L921,L917,L913

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L921,L917,L913|

```
_maxTxAmount = _tTotal.mul(maxTxPercent).div(10 ** 2)
_liquidityFee = liquidityFee
_taxFee = taxFee

```

##### Recommendation

Emit an event for critical parameter changes.