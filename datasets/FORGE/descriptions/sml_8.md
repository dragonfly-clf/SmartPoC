#### L07 - Missing Events Arithmetic

**Criticality** minor / informative

**Location** contract.sol#L938,934,930,963,926

**Status** Unresolved

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L938,934,930,963,926|
|Status|Unresolved|


_jpRatio = jpRatio
_moonFee = moonFee
_liquidityFee = liquidityFee
_maxTxAmount = _tTotal.mul(maxTxPercent).div(10 ** 2)
_taxFee = taxFee


##### Recommendation

Emit an event for critical parameter changes.


-----

