#### L07 - Missing Events Arithmetic

**Criticality** minor / informative

**Location** contract.sol#L1561,1514,1518,2508,1526,1480

**Status** Unresolved

##### Description

Detected missing events for critical arithmetic parameters. There are functions that
have no event emitted, so it is difficult to track off-chain changes.

|Criticality|minor / informative|
|---|---|
|Location|contract.sol#L1561,1514,1518,2508,1526,1480|
|Status|Unresolved|


minimumTokenBalanceForDividends = _minimumTokenBalanceForDividends
buyBackUpperLimit = buyBackLimit * 10 ** uint256(_decimals)
_maxTxAmount = _tTotal.mul(maxTxPercent).div(10 ** 4)
gasForProcessing = newValue
_maxWalletAmount = _tTotal.mul(maxWalletPercent).div(10 ** 4)
_taxFee = taxFee


##### Recommendation

Emit an event for critical parameter changes.


-----

