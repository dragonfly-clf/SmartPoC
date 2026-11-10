#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L523,526,529,532

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L523,526,529,532|

```
_maxTxAmount = _tTotal.mul(maxTxPercent).div(10 ** 3)
_liquidityFee = liquidityFee
_developmentFee = developmentFee
_taxFee = taxFee

```

##### Recommendation

Emit an event for critical parameter changes.


-----

