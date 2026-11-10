#### L07 - Missing Events Arithmetic

**Criticality** minor

**Location** contract.sol#L902,922,905,914,899

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor|
|---|---|
|Location|contract.sol#L902,922,905,914,899|


_taxFee = taxFee
_maxTxAmount = maxTxPercent * 10 ** 6 * 10 ** 9
_liquidityFee = liquidityFee
numTokensSellToAddToLiquidity = amount * 10 ** 6 * 10 ** 9
_DevFee = DevFee


##### Recommendation

Emit an event for critical parameter changes.


-----

