#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L640,644,648,652,908

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L640,644,648,652,908|

```
numTokensSellToAddToLiquidity = amountToUpdate
_maxTxAmount = maxTxPercent * 10 ** _decimals
_liquidityFee = liquidityFee
_devFee = devFee
_taxFee = taxFee

```

##### Recommendation

Emit an event for critical parameter changes.


-----

