#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L895,887,891,883

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L895,887,891,883|


_taxFee = taxFee
numTokensSellToAddToLiquidity = swapNumber * 10 ** _decimals
_liquidityFee = liquidityFee
_maxTxAmount = maxTxPercent * 10 ** _decimals


##### Recommendation

Emit an event for critical parameter changes.


-----

