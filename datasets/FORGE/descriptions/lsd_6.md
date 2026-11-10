#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L646,L505

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L646,L505|

```
_TAX_FEE = _txFee * 100
_maxTxAmount = _tTotal.mul(maxTxPercent).div(10 ** 4)

```

##### Recommendation

Emit an event for critical parameter changes.