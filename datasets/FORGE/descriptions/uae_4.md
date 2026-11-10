#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L652,640,644,648,908

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L652,640,644,648,908|


numTokensSellToAddToLiquidity = amountToUpdate
_liquidityFee = liquidityFee
_devFee = devFee
_taxFee = taxFee
_maxTxAmount = maxTxPercent * 10 ** _decimals


##### Recommendation

Emit an event for critical parameter changes.


-----

