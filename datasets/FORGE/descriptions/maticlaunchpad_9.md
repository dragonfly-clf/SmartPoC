#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L876,956,960,964

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L876,956,960,964|

```
_maxTxAmount = _tTotal.mul(maxTxPercent).div(10 ** 2)
_liquidityFee = liquidityFee
_taxFee = taxFee
sSUTCDateTime = _sSUTCDateTime

```

##### Recommendation

Emit an event for critical parameter changes.


-----

