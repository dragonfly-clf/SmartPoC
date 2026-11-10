#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L850,1011,1015,1019,1023,1027

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L850,1011,1015,1019,1023,1027|

```
_maxTxAmount = _tTotal.mul(maxTxPercent).div(10 ** 2)
_liquidityFee = liquidityFee
_charityFee = charityFee
_developerFee = developerFee
_taxFee = taxFee
_tTotal -= amount

```

##### Recommendation

Emit an event for critical parameter changes.


-----

