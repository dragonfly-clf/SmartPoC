#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L897,901,905,1253,1256

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L897,901,905,1253,1256|

```
_maxTxAmount = maxTxAmount
numTokensSellToAddToLiquidity = _selltokenswap
_maxTxAmount = _tTotal.mul(maxTxPercent).div(10 ** 2)
_liquidityFee = liquidityFee
_taxFee = taxFee

```

##### Recommendation

Emit an event for critical parameter changes.


-----

